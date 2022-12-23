import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney
import Tuple
import Views

let giftRedemptionLandingMiddleware:
  Middleware<
    StatusLineOpen, ResponseEnded,
    Tuple5<Gift.ID, User?, Models.Subscription?, SubscriberState, SiteRoute>, Data
  > =
    fetchAndValidateGiftAndDiscount
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: giftRedeemLanding(gift:subscriberState:currentUser:episodeStats:),
      layoutData: { gift, amount, user, subscription, subscriberState, route in
        SimplePageLayoutData(
          currentRoute: route,
          currentSubscriberState: subscriberState,
          currentUser: user,
          data: (gift, subscriberState, user, stats(forEpisodes: Current.episodes())),
          extraStyles: extraGiftLandingStyles <> testimonialStyle,
          style: .base(.some(.minimal(.black))),
          title: "Redeem your Point-Free gift"
        )
      }
    )

let giftRedemptionMiddleware:
  Middleware<
    StatusLineOpen, ResponseEnded, Tuple4<Gift.ID, User?, Models.Subscription?, SubscriberState>,
    Data
  > =
    fetchAndValidateGiftAndDiscount
    <<< filterMap(require3 >>> pure, or: loginAndRedirect)
    <| redeemGift

private func redeemGift(
  _ conn: Conn<
    StatusLineOpen, Tuple5<Gift, Cents<Int>, User, Models.Subscription?, SubscriberState>
  >
) -> IO<Conn<ResponseEnded, Data>> {
  let (gift, discount, user, subscription, subscriberState) = lower(conn.data)

  if let subscription = subscription, subscription.stripeSubscriptionStatus.isActive {
    guard subscriberState.isOwner
    else {
      return conn
      |> redirect(
        to: .gifts(.redeem(gift.id)),
        headersMiddleware: flash(
          .error,
          "You are already part of an active team subscription."
        )
      )
    }

    return EitherIO {
      try await Current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
    }
    .flatMap { stripeSubscription -> EitherIO<Error, Customer> in
      //        // TODO: Should we disallow gifts from applying to team subscriptions?
      //        guard stripeSubscription.quantity == 1
      //        else {
      //
      //        }

      return Current.stripe.updateCustomerBalance(
        stripeSubscription.customer.id,
        (stripeSubscription.customer.right?.balance ?? 0) - discount
      )
      .flatMap { customer in
        EitherIO {
          _ = try await Current.database.updateGift(gift.id, stripeSubscription.id)
          return customer
        }
      }
    }
    .run
    .flatMap { errorOrCustomer in
      switch errorOrCustomer {
      case .left:
        return conn
        |> redirect(
          to: .gifts(.redeem(gift.id)),
          headersMiddleware: flash(
            .error,
              """
              We were unable to redeem your gift. Please try again, or contact \
              <support@pointfree.co> for more help.
              """
          )
        )

      case .right:
        return conn
        |> redirect(
          to: .account(),
          headersMiddleware: flash(
            .notice,
            "The gift has been applied to your account as credit."
          )
        )
      }
    }
  } else {
    return EitherIO {
      let customer = try await Current.stripe.createCustomer(
        nil,
        user.id.rawValue.uuidString,
        user.email,
        nil,
        -discount
      )
      let stripeSubscription = try await Current.stripe
        .createSubscription(customer.id, gift.monthsFree < 12 ? .monthly : .yearly, 1, nil)
      _ = try await Current.database
        .createSubscription(stripeSubscription, user.id, true, nil)
      _ = try await Current.database.updateGift(gift.id, stripeSubscription.id)
    }
    .run
    .flatMap { errorOrNot in
      switch errorOrNot {
      case .left:
        return conn
          |> redirect(
            to: .gifts(.redeem(gift.id)),
            headersMiddleware: flash(
              .error,
              """
              We were unable to redeem your gift. Please try again, or contact \
              <support@pointfree.co> for more help.
              """
            )
          )

      case .right:
        return conn
          |> redirect(
            to: .account(),
            headersMiddleware: flash(.notice, "You now have access to Point-Free!")
          )
      }
    }
  }
}

private func fetchAndValidateGiftAndDiscount<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Gift, Cents<Int>, A>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, T2<Gift.ID, A>, Data> {

  return { conn in
    let (giftId, rest) = (conn.data.first, conn.data.second)
    return EitherIO<_, (Gift, PaymentIntent)> {
      let gift = try await Current.database.fetchGift(giftId)
      let paymentIntent = try await Current.stripe.fetchPaymentIntent(gift.stripePaymentIntentId)
      return (gift, paymentIntent)
    }
    .run
    .flatMap { errorOrGiftAndPaymentIntent in
      switch errorOrGiftAndPaymentIntent {
      case .left:
        return conn |> routeNotFoundMiddleware

      case let .right((gift, paymentIntent)):
        guard gift.stripeSubscriptionId == nil
        else {
          return conn
          |> redirect(
            to: .gifts(),
            headersMiddleware: flash(.error, "This gift was already redeemed.")
          )
        }

        return conn.map(const(gift .*. paymentIntent.amount .*. rest)) |> middleware
      }
    }
  }
}
