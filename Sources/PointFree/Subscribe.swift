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
  _requireUser
    <| subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<Database.User, SubscribeData?>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (user, subscribeData) = conn.data |> lower

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
