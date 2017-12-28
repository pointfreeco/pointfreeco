import Either
import Foundation
import HttpPipeline
import Prelude
import Tuple

public struct SubscribeData: Codable {
  public let pricing: Pricing
  public let token: Stripe.Token.Id
}

let subscribeMiddleware =
  require(require2)
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
      .flatMap { AppEnvironment.current.database.createSubscription($0.id, user.id).withExcept(const(unit)) }
      .run
      .flatMap { subscription -> IO<Conn<ResponseEnded, Data>> in

        switch subscription {
        case .left:
          return conn
            |> writeStatus(.internalServerError)
            >-> respond(text: "Error creating subscription!")

        case .right:
          return conn
            |> redirect(to: path(to: .account))
        }
    }
}
