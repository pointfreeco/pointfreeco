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
      @Dependency(\.episodes) var episodes
      return SimplePageLayoutData(
        data: (gift, stats(forEpisodes: episodes())),
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
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe
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
            "You are already part of an active team."
          )
        )
    }

    return EitherIO {
      let stripeSubscription =
        try await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      // TODO: Should we disallow gifts from applying to team subscriptions?
      //guard stripeSubscription.quantity == 1
      //else {
      //  throw unit
      //}
      async let customer = stripe.updateCustomerBalance(
        stripeSubscription.customer.id,
        (stripeSubscription.customer.right?.balance ?? 0) - discount
      )
      async let gift = database.updateGift(id: gift.id, subscriptionID: stripeSubscription.id)
      _ = try await (customer, gift)
    }
    .run
    .flatMap { errorOrCustomer in
      switch errorOrCustomer {
      case .left(let error):
        reportIssue(error)
        let message =
          (error as? StripeErrorEnvelope).map(\.error.message)
          ?? """
          We were unable to redeem your gift. Please try again, or contact \
          <support@pointfree.co> for more help.
          """
        return conn
          |> redirect(
            to: .gifts(.redeem(gift.id)),
            headersMiddleware: flash(.error, message)
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
      let customer = try await stripe.createCustomer(
        nil,
        currentUser.id.rawValue.uuidString,
        currentUser.email,
        nil,
        -discount
      )
      let stripeSubscription =
        try await stripe
        .createSubscription(
          customerID: customer.id,
          planID: try await resolvePlanID(
            for: .init(
              plan: gift.plan,
              billing: gift.monthsFree < 12 ? .monthly : .yearly,
              quantity: 1
            )
          ),
          quantity: 1,
          coupon: nil
        )
      _ =
        try await database.createSubscription(
          subscription: stripeSubscription,
          userID: currentUser.id,
          isOwnerTakingSeat: true,
          referrerID: nil,
          plan: gift.plan
        )
      _ = try await database.updateGift(id: gift.id, subscriptionID: stripeSubscription.id)
    }
    .run
    .flatMap { errorOrNot in
      switch errorOrNot {
      case .left(let error):
        reportIssue(error)
        let message =
          (error as? StripeErrorEnvelope).map(\.error.message)
          ?? """
          We were unable to redeem your gift. Please try again, or contact \
          <support@pointfree.co> for more help.
          """
        return conn
          |> redirect(
            to: .gifts(.redeem(gift.id)),
            headersMiddleware: flash(.error, message)
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
  @Dependency(\.database) var database

  return { conn in
    let giftId = conn.data
    return EitherIO<_, (Gift, Cents<Int>)> {
      let gift = try await database.fetchGift(id: giftId)
      let billing: Pricing.Billing = gift.monthsFree < 12 ? .monthly : .yearly
      let price = try await resolvePrice(
        for: Pricing(plan: gift.plan, billing: billing, quantity: 1)
      )
      guard let unitAmount = price.unitAmount else {
        reportIssue("Price has no unit amount")
        throw unit
      }
      let numberOfPeriods = gift.monthsFree < 12 ? gift.monthsFree : gift.monthsFree / 12
      let discount: Cents<Int> = .init(rawValue: unitAmount.rawValue * numberOfPeriods)
      return (gift, discount)
    }
    .run
    .flatMap { errorOrGiftAndDiscount in
      switch errorOrGiftAndDiscount {
      case .left:
        return IO { routeNotFoundMiddleware(conn)}

      case let .right((gift, discount)):
        guard gift.stripeSubscriptionId == nil
        else {
          return conn
            |> redirect(
              to: .gifts(),
              headersMiddleware: flash(.error, "This gift was already redeemed.")
            )
        }

        return conn.map(const((gift, discount))) |> middleware
      }
    }
  }
}
