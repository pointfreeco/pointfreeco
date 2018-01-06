import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import Tuple

public struct SubscribeData: Codable {
  public let pricing: Pricing
  public let token: Stripe.Token.Id
}

let subscribeMiddleware =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <| subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<SubscribeData?, Database.User>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscribeData, user) = conn.data |> lower

    return pure(subscribeData)
      .mapExcept(requireSome)
      .withExcept(const(unit))
      .flatMap { subscribeData in
        AppEnvironment.current.stripe.createCustomer(user, subscribeData.token)
          .map { ($0, subscribeData) }
      }
      .flatMap {
        AppEnvironment.current.stripe
          .createSubscription($0.id, $1.pricing.plan, $1.pricing.quantity)
      }
      .flatMap { stripeSubscription in
        AppEnvironment.current.database.createSubscription(stripeSubscription, user.id)
          .withExcept(const(unit))
          .map(const(stripeSubscription))
      }
      .run
      .flatMap { errorOrStripeSubscription -> IO<Conn<ResponseEnded, Data>> in

        switch errorOrStripeSubscription {
        case .left:
          return conn
            |> writeStatus(.internalServerError)
            >-> respond(text: "Error creating subscription!")

        case let .right(stripeSubscription):
          return conn
            |> redirect(to: .account(.index), headersMiddleware:
              // todo
              writeSessionCookieMiddleware(\.subscriptionStatus .~ stripeSubscription.status)
                >-> flash(.notice, "You are now subscribed to Point-Free!")
          )
        }
    }
}
