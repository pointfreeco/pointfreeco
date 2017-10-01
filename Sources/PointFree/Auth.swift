import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude

let secretHomeResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  writeStatus(.ok)
    >>> readCookieMiddleware
    >>> respond(secretHomeView)
    >>> pure

let githubCallbackResponse =
  authTokenMiddleware
    >-> redirect(to: link(to: .secretHome), headersMiddleware: writeCookieMiddleware)
    >>> pure

let loginResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  redirect(to: githubAuthorizationUrl)
    >>> pure

let logoutResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  redirect(
    to: link(to: .secretHome),
    headersMiddleware: writeHeader(.clearCookie(key: "github_session"))
    )
    >>> pure

private let secretHomeView = View<Either<Prelude.Unit, GitHubUserEnvelope>> { data in
  [
    p(["welcome home"]),

    p([
      text(
        data.right.map { "You are logged in as \($0.gitHubUser.name)" }
          ?? "You are not logged in"
      )
      ]),

    p([
       data.isRight
        ? a([href(link(to: .logout))], ["Log out"])
        : a([href(link(to: .login))], ["Log in"])
      ])
    ]
}

// todo: move to swift-web
extension URLRequest {
  public var cookies: [String: String] {
    let pairs = (self.allHTTPHeaderFields?["Cookie"] ?? "")
      .components(separatedBy: "; ")
      .map {
        $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
          .map(String.init)
      }
      .flatMap { pure(createTuple) <*> $0.first <*> $0.last }
    return .init(uniqueKeysWithValues: pairs)
  }
}

// todo: move to prelude
private func createTuple<A, B>(_ a: A) -> (B) -> (A, B) {
  return { b in (a, b) }
}

private func readCookieMiddleware(
  _ conn: Conn<HeadersOpen, Prelude.Unit>
  )
  -> Conn<HeadersOpen, Either<Prelude.Unit, GitHubUserEnvelope>> {

    return conn.map(
      const(
        conn.request.cookies["github_session"]
          .flatMap { ResponseHeader.verifiedValue(signedCookieValue: $0, secret: EnvVars.appSecret) }
          .map(Either.right)
          ?? Either.left(unit)
      )
    )
}

private func writeCookieMiddleware(
  _ conn: Conn<HeadersOpen, Either<Prelude.Unit, GitHubUserEnvelope>>
  )
  -> Conn<HeadersOpen, Either<Prelude.Unit, GitHubUserEnvelope>> {

    switch conn.data {
    case .left:
      return conn
    case let .right(envelope):
      return conn |> writeHeaders(
        [
          ResponseHeader.setSignedCookie(
            key: "github_session",
            value: envelope,
            options: [],
            secret: EnvVars.appSecret,
            encrypt: true
          )
          ] |> catOptionals
      )
    }
}

/// Exchanges a github code for an access token and loads the user's data.
private func authTokenMiddleware<I>(
  _ conn: Conn<I, String>
  )
  -> IO<Conn<I, Either<Prelude.Unit, GitHubUserEnvelope>>> {

    return AppEnvironment.current.fetchAuthToken(conn.data)
      .flatMap { token in
        AppEnvironment.current.fetchGitHubUser(token)
          .map { user in GitHubUserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .run
      .map { conn.map(const($0)) }
}

private let githubAuthorizationUrl =
  "https://github.com/login/oauth/authorize?scope=user:email&client_id=\(EnvVars.GitHub.clientId)"
