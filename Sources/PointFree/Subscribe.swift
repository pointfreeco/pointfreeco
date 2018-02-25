import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import Tuple

public struct SubscribeData: Codable {
  public let pricing: Pricing
  public let token: Stripe.Token.Id
  public let vatNumber: String
}

let subscribeMiddleware =
  filterMap(
    require1 >>> pure,
    or: redirect(to: .pricing(nil, expand: nil), headersMiddleware: flash(.error, "Error creating subscription!"))
    )
    <<< filter(
      get1 >>> ^\.pricing >>> validateQuantity,
      or: redirect(to: .pricing(nil, expand: nil), headersMiddleware: flash(.error, "An invalid subscription quantity was used."))
    )
    <<< redirectActiveSubscribers(user: get2)
    <<< filterMap(require2 >>> pure, or: loginAndRedirectToPricing)
    <| subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<SubscribeData, Database.User>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscribeData, user) = conn.data
      |> lower

    let subscriptionOrError = (pure(subscribeData) as EitherIO<Error, SubscribeData>)
      .withExcept(const(unit))
      .flatMap { subscribeData in
        AppEnvironment.current.stripe
          .createCustomer(user, subscribeData.token, subscribeData.vatNumber.isEmpty ? nil : subscribeData.vatNumber)
          .map { ($0, subscribeData) }
      }
      .flatMap {
        AppEnvironment.current.stripe
          .createSubscription($0.id, $1.pricing.plan, $1.pricing.quantity)
      }
      .flatMap { stripeSubscription in
        AppEnvironment.current.database
          .createSubscription(stripeSubscription, user.id)
          .withExcept(const(unit))
          .map(const(stripeSubscription))
      }
      .run

    return subscriptionOrError.flatMap(
      either(
        const(
          conn
            |> redirect(
              to: .pricing(subscribeData.pricing, expand: nil),
              headersMiddleware: flash(.error, "Error creating subscription!")
          )
        ),
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
    |> redirect(to: .login(redirect: url(to: .pricing(get1(conn.data).pricing, expand: nil))))
}
