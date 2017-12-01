import Foundation
import HttpPipeline
import Prelude

struct RequestContext<A> {
  private(set) var data: A
  private(set) var currentUser: User? = nil
  private(set) var currentRequest: URLRequest

  func map<B>(_ f: (A) -> B) -> RequestContext<B> {
    return .init(
      data: f(self.data),
      currentUser: self.currentUser,
      currentRequest: self.currentRequest
    )
  }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (RequestContext<A>) -> RequestContext<B> {
  return { $0.map(f) }
}

private func extractedGitHubUserEnvelope(from request: URLRequest) -> GitHubUserEnvelope? {
  return request.cookies[githubSessionCookieName]
    .flatMap {
      ResponseHeader.verifiedValue(
        signedCookieValue: $0,
        secret: AppEnvironment.current.envVars.appSecret
      )
  }
}

func requestContextMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<StatusLineOpen, RequestContext<A>>> {

  return pure(
    conn.map(
      const(
        RequestContext(
          data: conn.data,
          currentUser: nil,
          currentRequest: conn.request
        )
      )
    )
    )
    >>- _fetch(currentUser: \.currentUser)
}

func _fetch<A, I>(currentUser keyPath: WritableKeyPath<A, User?>) -> Middleware<I, I, A, A> {

  return { conn in
    let currentUser = extractedGitHubUserEnvelope(from: conn.request)
      .map {
        AppEnvironment.current.fetchUser($0.accessToken)
          .run
          .map(get(\.right) >>> flatMap(id))
      }
      ?? pure(nil)

    return (currentUser.map(set(keyPath)) <*> pure(conn.data))
      .map { conn.map(const($0)) }
  }
}

