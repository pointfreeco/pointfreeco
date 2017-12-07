import Foundation
import HttpPipeline
import Prelude
@testable import Tuple

typealias SubscribeData = (plan: Stripe.Plan.Id, token: String)

let subscribeResponse:
  Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User?, SubscribeData>, Data> =
    currentUserMiddleware
      >-> { conn in pure(conn.map { Tuple(first: $0, second: unit) }) }
      >-> subscribe

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<Database.User?, SubscribeData>>)
  -> IO<Conn<ResponseEnded, Data>> {

    return AppEnvironment.current.stripe.createCustomer(conn.data.second.first.token)
      .flatMap { AppEnvironment.current.stripe.createSubscription($0.id, conn.data.second.first.plan) }
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
