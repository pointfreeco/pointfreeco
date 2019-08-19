import Either
import Foundation
import HttpPipeline
import Models
import Optics
import PointFreeRouter
import Prelude
import Stripe
import Tuple

let subscribeMiddleware =
  filterMap(
    require1 >>> pure,
    or: redirect(
      with: get1 >>> subscribeConfirmationWithSubscribeData,
      headersMiddleware: flash(.error, "Error creating subscription!")
    )
    )
    <<< filter(
      get1 >>> ^\.pricing >>> validateQuantity,
      or: redirect(
        with: get1 >>> subscribeConfirmationWithSubscribeData,
        headersMiddleware: flash(.error, "An invalid subscription quantity was used.")
      )
    )
    <<< filter(
      get1 >>> validateCoupon(forSubscribeData:),
      or: redirect(
        with: get1 >>> subscribeConfirmationWithSubscribeData,
        headersMiddleware: flash(.error, "Coupons can only be used on individual subscription plans.")
      )
    )
    <<< redirectActiveSubscribers(user: get2)
    <<< filterMap(require2 >>> pure, or: loginAndRedirectToPricing)
    <| subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<SubscribeData, User>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscribeData, user) = conn.data
      |> lower

    let subscriptionOrError = (pure(subscribeData) as EitherIO<Error, SubscribeData>)
      .withExcept(const(unit))
      .flatMap { subscribeData in
        Current.stripe
          .createCustomer(subscribeData.token, user.id.rawValue.uuidString, user.email, nil)
          .map { ($0, subscribeData) }
          .flatMap {
            Current.stripe
              .createSubscription($0.id, $1.pricing.plan, $1.pricing.quantity, $1.coupon)
        }
        .flatMap { stripeSubscription -> EitherIO<Error, Models.Subscription?> in
          let parallel = sequence(
            subscribeData.teammates
              .filter { email in email.rawValue.contains("@") && email != user.email }
              .prefix(subscribeData.pricing.quantity - 1)
              .map { email in
                Current.database.insertTeamInvite(email, user.id)
                  .flatMap { invite in sendInviteEmail(invite: invite, inviter: user) }
                  .run
                  .parallel
            }
          ).map(const(unit))

          return lift(parallel.sequential).flatMap { _ in
            Current.database
              .createSubscription(stripeSubscription, user.id)
          }
        }
    }
    .run

    return subscriptionOrError.flatMap(
      either(
        { error in
          let errorMessage = (error as? StripeErrorEnvelope)?.error.message
            ?? "Error creating subscription!"
          return conn
            |> redirect(
              to: subscribeConfirmationWithSubscribeData(subscribeData),
              headersMiddleware: flash(.error, errorMessage)
          )
      },
        const(
          conn
            |> redirect(
              to: .account(.index),
              headersMiddleware: flash(.notice, "You are now subscribed to Point-Free!")
          )
        )
      )
    )
}

private func validateQuantity(_ pricing: Pricing) -> Bool {
  return !pricing.isTeam || Pricing.validTeamQuantities.contains(pricing.quantity)
}

private func loginAndRedirectToPricing<A>(
  _ conn: Conn<StatusLineOpen, T2<SubscribeData, A>>
  )
  -> IO<Conn<ResponseEnded, Data>> {

  return conn
    |> redirect(to: .login(redirect: url(to: .pricingLanding)))
}

private func validateCoupon(forSubscribeData subscribeData: SubscribeData) -> Bool {
  return subscribeData.coupon == nil || subscribeData.pricing.quantity == 1
}

private func subscribeConfirmationWithSubscribeData(_ subscribeData: SubscribeData?) -> Route {
  return .subscribeConfirmation(
    subscribeData?.pricing.isPersonal == .some(true) ? .personal : .team,
    subscribeData?.pricing.billing,
    subscribeData?.teammates
  )
}
