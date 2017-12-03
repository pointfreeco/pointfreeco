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

func requestContextMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<StatusLineOpen, RequestContext<A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn.request)
    .map {
      AppEnvironment.current.database.fetchUser($0.accessToken)
        .run
        .map(get(\.right) >>> flatMap(id))
    }
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

///
private func extractedGitHubUserEnvelope(from request: URLRequest) -> GitHub.UserEnvelope? {
  return request.cookies[gitHubSessionCookieName]
    .flatMap {
      ResponseHeader.verifiedValue(
        signedCookieValue: $0,
        secret: AppEnvironment.current.envVars.appSecret
      )
  }
}
