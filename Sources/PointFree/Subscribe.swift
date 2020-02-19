import Either
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Stripe
import Tuple

let subscribeMiddleware
  = validateUser
    <<< validateSubscribeData
    <| subscribe

private let validateUser
  : MT<Tuple2<User?, SubscribeData?>, Tuple2<User, SubscribeData?>>
  = redirectActiveSubscribers(user: get1)
    <<< filterMap(require1 >>> pure, or: loginAndRedirectToPricing)

private let validateSubscribeData
  : MT<Tuple2<User, SubscribeData?>, Tuple3<User, SubscribeData, User?>>
  = requireSubscribeData
    <<< validateQuantity
    <<< validateCoupon
    <<< validateReferrer

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple3<User, SubscribeData, User?>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (user, subscribeData, referrer) = lower(conn.data)

    let subscriptionOrError = Current.stripe
      .createCustomer(subscribeData.token, user.id.rawValue.uuidString, user.email, nil)
      .flatMap { customer in
        Current.stripe.createSubscription(
          customer.id,
          subscribeData.pricing.plan,
          subscribeData.pricing.quantity,
          subscribeData.coupon
        )
      }
      .flatMap { stripeSubscription -> EitherIO<Error, Models.Subscription?> in
        Current.database
          .createSubscription(stripeSubscription, user.id, subscribeData.isOwnerTakingSeat, referrer?.id)
          .flatMap { subscription in
            sendInviteEmails(inviter: user, subscribeData: subscribeData)
              .map(const(subscription))
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

private func sendInviteEmails(inviter: User, subscribeData: SubscribeData) -> EitherIO<Error, Prelude.Unit> {
  return lift(
    sequence(
      subscribeData.teammates
        .filter { email in email.rawValue.contains("@") && email != inviter.email }
        .prefix(subscribeData.pricing.quantity - (subscribeData.isOwnerTakingSeat ? 1 : 0))
        .map { email in
          Current.database.insertTeamInvite(email, inviter.id)
            .flatMap { invite in sendInviteEmail(invite: invite, inviter: inviter) }
            .run
            .parallel
    })
      .sequential
  )
  .map(const(unit))
  .catch(const(pure(unit)))
}

private func validateQuantity(_ pricing: Pricing) -> Bool {
  return !pricing.isTeam || Pricing.validTeamQuantities.contains(pricing.quantity)
}

private func loginAndRedirectToPricing<A>(
  _ conn: Conn<StatusLineOpen, A>
  )
  -> IO<Conn<ResponseEnded, Data>> {

  return conn
    |> redirect(to: .login(redirect: url(to: .pricingLanding)))
}

private func validateCoupon(forSubscribeData subscribeData: SubscribeData) -> Bool {
  return subscribeData.coupon == nil || subscribeData.pricing.quantity == 1
}

private func subscribeConfirmationWithSubscribeData(_ subscribeData: SubscribeData?) -> Route {
  guard let subscribeData = subscribeData else {
    return .subscribeConfirmation(
      lane: .team,
      billing: .yearly,
      isOwnerTakingSeat: true,
      teammates: [""],
      referralCode: nil
    )
  }
  guard let coupon = subscribeData.coupon else {
    return .subscribeConfirmation(
      lane: subscribeData.pricing.isPersonal ? .personal : .team,
      billing: subscribeData.pricing.billing,
      isOwnerTakingSeat: subscribeData.isOwnerTakingSeat,
      teammates: subscribeData.teammates,
      referralCode: subscribeData.referralCode
    )
  }
  return .discounts(code: coupon, subscribeData.pricing.billing)
}

private func requireSubscribeData(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData?>, Data> {
  return middleware |> filterMap(
    require2 >>> pure,
    or: redirect(
      with: get2 >>> subscribeConfirmationWithSubscribeData,
      headersMiddleware: flash(.error, "Error creating subscription!")
    )
  )
}

private func validateQuantity(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return middleware |> filter(
    get2 >>> ^\.pricing >>> validateQuantity,
    or: redirect(
      with: get2 >>> subscribeConfirmationWithSubscribeData,
      headersMiddleware: flash(.error, "An invalid subscription quantity was used.")
    )
  )
}

private func validateCoupon(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return middleware |> filter(
    get2 >>> validateCoupon(forSubscribeData:),
    or: redirect(
      with: get2 >>> subscribeConfirmationWithSubscribeData,
      headersMiddleware: flash(.error, "Coupons can only be used on individual subscription plans.")
    )
  )
}

private func validateReferrer(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple3<User, SubscribeData, User?>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return { conn in
    let (user, subscribeData) = lower(conn.data)
    return middleware(conn.map(const(user .*. subscribeData .*. nil .*. unit)))
  }
}
