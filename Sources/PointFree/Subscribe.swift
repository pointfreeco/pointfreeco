import Foundation
import HttpPipeline
import Prelude
@testable import Tuple

typealias SubscribeData = (plan: Stripe.Plan.Id, token: String)

let subscribeResponse =
    currentUserMiddleware
      >-> subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, T2<Database.User?, SubscribeData>>)
  -> IO<Conn<ResponseEnded, Data>> {

    return AppEnvironment.current.stripe.createCustomer(conn.data.second.token)
      .flatMap { AppEnvironment.current.stripe.createSubscription($0.id, conn.data.second.plan) }
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
            >-> respond(text: "Created subscription! id: " + sub.id)
        }
    }
}
