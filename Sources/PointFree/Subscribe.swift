import Foundation
import HttpPipeline
import Prelude
@testable import Tuple

typealias SubscribeData = (plan: Stripe.Plan.Id, token: Stripe.Token.Id)

let subscribeResponse =
  map { $0 .*. unit }
    >>> currentUserMiddleware
    >-> subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<Database.User?, SubscribeData>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (currentUser, subscribeData) = conn.data |> lower
    guard let user = currentUser else { fatalError() }
    return AppEnvironment.current.stripe.createCustomer(user, subscribeData.token)
      .flatMap { AppEnvironment.current.stripe.createSubscription($0.id, subscribeData.plan) }
      .run
      .flatMap { subscription -> IO<Conn<ResponseEnded, Data>> in

        switch subscription {
        case .left:
          return conn
            |> writeStatus(.internalServerError)
            >-> respond(text: "Error creating subscription!")

        case let .right(sub):
          return conn
            |> writeStatus(.created)
            >-> respond(text: "Created subscription! id: " + sub.id.unwrap)
        }
    }
}
