import Foundation
import HttpPipeline
import Prelude
import Html
import HttpPipelineHtmlSupport
@testable import Tuple // FIXME

/// A value that wraps any given data with additional context that is useful for completing the
/// request-to-response lifecycle.
struct RequestContext<A> {
  private(set) var currentUser: Database.User? = nil
  private(set) var currentRequest: URLRequest
  private(set) var data: A

  func map<B>(_ f: (A) -> B) -> RequestContext<B> {
    return .init(
      currentUser: self.currentUser,
      currentRequest: self.currentRequest,
      data: f(self.data)
    )
  }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (RequestContext<A>) -> RequestContext<B> {
  return { $0.map(f) }
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

public func requireUser<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User, A>, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { conn in
      (conn |> readSessionCookieMiddleware)
        .flatMap { c in
          get1(c.data).map { user in
            c.map(const(user .*. get2(c.data)))
              |> middleware
            }
            ?? (conn |> redirect(to: .login(redirect: conn.request.url?.absoluteString)))
      }
    }
}

func currentUserMiddleware<A, I>(
  _ conn: Conn<I, A>
  ) -> IO<Conn<I, Tuple2<Database.User?, A>>> {

  return conn |> readSessionCookieMiddleware
}

// todo: maybe do this, maybe not
//public func .*. <A, B> (lhs: A, rhs: B) -> Tuple<A, B> {
//  return .init(first: lhs, second: rhs)
//}

//func currentRequestMiddleware<A, I>(
//  _ conn: Conn<I, A>
//  ) -> IO<Conn<I, T2<URLRequest, A>>> {
//
//  return pure <|
//    conn.map(
//      const(conn.request .*. conn.data)
//  )
//}

func requestContextMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<StatusLineOpen, RequestContext<A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn.request)
    .map(fetchDatabaseUser)
    ?? pure(nil)

  return currentUser.map {
    conn.map(
      const(
        RequestContext(
          currentUser: $0,
          currentRequest: conn.request,
          data: conn.data
        )
      )
    )
  }
}

func extractedGitHubUserEnvelope(from request: URLRequest) -> Database.User.Id? {
  return request.cookies[pointFreeUserSession]
    .flatMap {
      ResponseHeader.verifiedValue(
        signedCookieValue: $0,
        secret: AppEnvironment.current.envVars.appSecret
      )
  }
}

private let fetchDatabaseUser: (Database.User.Id) -> IO<Database.User?> =
  AppEnvironment.current.database.fetchUserById
    >>> ^\.run
    >>> map(^\.right >>> flatMap(id))
