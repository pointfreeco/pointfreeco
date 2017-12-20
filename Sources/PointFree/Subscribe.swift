import Foundation
import HttpPipeline
import Prelude
import Tuple

public struct SubscribeData: Codable {
  public let pricing: Pricing
  public let token: Stripe.Token.Id
}

let subscribeResponse =
  requireUser
    <| subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<Database.User, SubscribeData>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (user, subscribeData) = conn.data |> lower
    return AppEnvironment.current.stripe.createCustomer(user, subscribeData.token)
      .flatMap {
        AppEnvironment.current.stripe
          .createSubscription($0.id, subscribeData.pricing.plan, subscribeData.pricing.quantity)
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
            |> writeStatus(.created)
            >-> respond(text: "Created subscription!")
        }
    }
}
