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

func currentUserMiddleware<A, I>(
  _ conn: Conn<I, A>
  ) -> IO<Conn<I, T2<Database.User?, A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn.request)
    .map {
      AppEnvironment.current.database.fetchUserByGitHub($0.accessToken)
        .run
        .map(^\.right >>> flatMap(id))
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

func requestContextMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<StatusLineOpen, RequestContext<A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn.request)
    .map(
      ^\.accessToken
        >>> AppEnvironment.current.database.fetchUserByGitHub
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
  return request.cookies[pointFreeUserSession]
    .flatMap {
      ResponseHeader.verifiedValue(
        signedCookieValue: $0,
        secret: AppEnvironment.current.envVars.appSecret
      )
  }
}
