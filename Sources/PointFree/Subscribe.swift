import Foundation
import HttpPipeline
import Prelude
@testable import Tuple

public struct SubscribeData: Codable {
  public let plan: Stripe.Plan.Id
  public let token: Stripe.Token.Id
}

//func _requireUser<A>(
//  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data>)
//  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data> {
//
//    return { conn in
//      return conn.data.first
//        .map { user in conn.map { T2(first: user, second: $0.second) } }
//        .map(middleware)
//        ?? (conn.map(const(unit)) |> redirect(to: path(to: .login(redirect: conn.request.url?.absoluteString))))
//    }
//}

func __requireUser<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

  return { conn in

    let currentUser = extractedGitHubUserEnvelope(from: conn.request)
      .map {
        AppEnvironment.current.database.fetchUserByGitHub($0.accessToken)
          .run
          .map(^\.right >>> flatMap(id))
      }
      ?? pure(nil)

    return currentUser.flatMap { user in
      user.map { conn.map(const($0 .*. conn.data)) |> middleware }
      ?? (conn |> redirect(to: path(to: .login(redirect: conn.request.url?.absoluteString))))
    }
  }
}

let subscribeResponse =
  __requireUser
    <|
//    (
//      map { $0 .*. unit }
//        >>>
        subscribe
//)

private func subscribe(_ conn: Conn<StatusLineOpen, Tuple2<Database.User, SubscribeData>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (user, subscribeData) = conn.data |> lower
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

