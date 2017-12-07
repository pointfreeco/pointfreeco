import Foundation
import HttpPipeline
import Prelude

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

@testable import Tuple

public func requireUser<A>(
  notFoundView: View<Prelude.Unit>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data> {


    return { middleware in
      return { conn in
        return conn.data.first
          .map { user in conn.map { T2(first: user, second: $0.second) } }
          .map(middleware)
          ?? (conn.map(const(unit)) |> (writeStatus(.notFound) >-> respond(notFoundView)))
      }
    }
}
//public func requireSome<A>(
//  notFoundView: View<Prelude.Unit>
//  )
//  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
//  -> Middleware<StatusLineOpen, ResponseEnded, A?, Data> {
//
//    return { middleware in
//      return { conn in
//        return conn.data
//          .map { conn.map(const($0)) }
//          .map(middleware)
//          ?? (conn.map(const(unit)) |> (writeStatus(.notFound) >-> respond(notFoundView)))
//      }
//    }
//}


func currentUserMiddleware<A, I>(
  _ conn: Conn<I, A>
  ) -> IO<Conn<I, T2<Database.User?, A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn.request)
    .map {
      AppEnvironment.current.database.fetchUser($0.accessToken)
        .run
        .map(get(\.right) >>> flatMap(id))
    }
    ?? pure(nil)

  return currentUser.map { user in
    conn.map(
      const(user .*. conn.data)
    )
  }
}

// todo: maybe do this, maybe not
public func .*. <A, B> (lhs: A, rhs: B) -> Tuple<A, B> {
  return .init(first: lhs, second: rhs)
}

func currentRequestMiddleware<A, I>(
  _ conn: Conn<I, A>
  ) -> IO<Conn<I, T2<URLRequest, A>>> {

  return pure <|
    conn.map(
      const(conn.request .*. conn.data)
  )
}

private let _middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  currentRequestMiddleware
    >-> currentUserMiddleware
    >-> writeStatus(.ok)
    >-> respond(_view)

import Html
import HttpPipelineHtmlSupport
private let _view = View<Tuple2<Database.User?, URLRequest>> { _ in
  []
}


func _requestContextMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<StatusLineOpen, Tuple3<Database.User?, URLRequest, A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn.request)
    .map(
      ^\.accessToken
        >>> AppEnvironment.current.database.fetchUser
        >>> ^\.run
        >>> map(^\.right >>> flatMap(id))
    )
    ?? pure(nil)

  return currentUser.map {
    conn.map(
      const($0 .*. conn.request .*. conn.data)
    )
  }
}

func requestContextMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<StatusLineOpen, RequestContext<A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn.request)
    .map(
      ^\.accessToken
        >>> AppEnvironment.current.database.fetchUser
        >>> ^\.run
        >>> map(^\.right >>> flatMap(id))
    )
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

func extractedGitHubUserEnvelope(from request: URLRequest) -> GitHub.UserEnvelope? {
  return request.cookies[gitHubSessionCookieName]
    .flatMap {
      ResponseHeader.verifiedValue(
        signedCookieValue: $0,
        secret: AppEnvironment.current.envVars.appSecret
      )
  }
}
