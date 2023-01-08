import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney
import Tuple
import Views

let giftRedemptionLandingMiddleware: Middleware<StatusLineOpen, ResponseEnded, Gift.ID, Data> =
  fetchAndValidateGiftAndDiscount
  <| writeStatus(.ok)
  >=> respond(
    view: giftRedeemLanding(gift:episodeStats:),
    layoutData: { gift, amount in
      SimplePageLayoutData(
        data: (gift, stats(forEpisodes: Current.episodes())),
        extraStyles: extraGiftLandingStyles <> testimonialStyle,
        style: .base(.some(.minimal(.black))),
        title: "Redeem your Point-Free gift"
      )
    }
  )

let giftRedemptionMiddleware: Middleware<StatusLineOpen, ResponseEnded, Gift.ID, Data> =
  fetchAndValidateGiftAndDiscount
  <| redeemGift

private func redeemGift(
  _ conn: Conn<StatusLineOpen, (Gift, Cents<Int>)>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.subscription) var subscription

  guard let currentUser = currentUser
  else { return loginAndRedirect(conn) }

  let (gift, discount) = conn.data

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
      let stripeSubscription = try await Current.stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      // TODO: Should we disallow gifts from applying to team subscriptions?
      //guard stripeSubscription.quantity == 1
      //else {
      //  throw unit
      //}
      async let customer = Current.stripe.updateCustomerBalance(
        stripeSubscription.customer.id,
        (stripeSubscription.customer.right?.balance ?? 0) - discount
      )
      async let gift = Current.database.updateGift(gift.id, stripeSubscription.id)
      _ = try await (customer, gift)
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
        currentUser.id.rawValue.uuidString,
        currentUser.email,
        nil,
        -discount
      )
      let stripeSubscription = try await Current.stripe
        .createSubscription(customer.id, gift.monthsFree < 12 ? .monthly : .yearly, 1, nil)
      _ = try await Current.database
        .createSubscription(stripeSubscription, currentUser.id, true, nil)
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

private func fetchAndValidateGiftAndDiscount(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, (Gift, Cents<Int>), Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Gift.ID, Data> {

  return { conn in
    let giftId = conn.data
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

        return conn.map(const((gift, paymentIntent.amount))) |> middleware
      }
    }
  }
}
