import Either
import Foundation
import Html
@testable import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude

let secretHomeResponse: (Conn<StatusLineOpen, Never, Prelude.Unit>) -> IO<Conn<ResponseEnded, Never, Data>> =
  writeStatus(.ok)
    >-> readGitHubSessionCookieMiddleware >>> map(optionalizeErrors)
    >-> respond(secretHomeView)

func promoteErrors<I, E, A>(_ conn: Conn<I, E, A>) -> Conn<I, Never, Either<E, A>> {
  return conn.mapConn(const(.right(conn.data)))
}

func optionalizeErrors<I, E, A>(_ conn: Conn<I, E, A>) -> Conn<I, Never, A?> {
  return conn.mapConn(const(.right(conn.data.right)))
}

let githubCallbackResponse =
  authTokenMiddleware

/// Redirects to GitHub authorization and attaches the redirect specified in the connection data.
let loginResponse: Middleware<StatusLineOpen, ResponseEnded, Never, Never, String?, Data> =
  { $0 |> redirect(to: githubAuthorizationUrl(withRedirect: $0.data.right!)) }

let logoutResponse: (Conn<StatusLineOpen, Never, Prelude.Unit>) -> IO<Conn<ResponseEnded, Never, Data>> =
  redirect(
    to: path(to: .secretHome),
    headersMiddleware: writeHeader(.clearCookie(key: githubSessionCookieName))
    )

private let secretHomeView = View<GitHubUserEnvelope?> { env in
  [
    p(["welcome home"]),

    p([
      text(
        env.map { "You are logged in as \($0.gitHubUser.name)" }
          ?? "You are not logged in"
      )
      ]),

    p([
       env != nil
        ? a([href(path(to: .logout))], ["Log out"])
        : a([href(path(to: .login(redirect: url(to: .secretHome))))], ["Log in"])
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
      .flatMap { tuple <¢> $0.first <*> $0.last }
    return .init(uniqueKeysWithValues: pairs)
  }
}

private func readGitHubSessionCookieMiddleware(
  _ conn: Conn<HeadersOpen, Never, Prelude.Unit>
  )
  -> IO<Conn<HeadersOpen, Prelude.Unit, GitHubUserEnvelope>> {

    let tmp1: Either<Prelude.Unit, GitHubUserEnvelope> =
      conn.request.cookies[githubSessionCookieName]
        .flatMap { ResponseHeader.verifiedValue(signedCookieValue: $0, secret: EnvVars.appSecret) }
        .map(Either.right)
        ?? Either.left(unit)

    return pure <| conn.mapConn(const(tmp1))
}

private func writeGitHubSessionCookieMiddleware(
  _ conn: Conn<HeadersOpen, Error, GitHubUserEnvelope>
  )
  -> IO<Conn<HeadersOpen, Error, GitHubUserEnvelope>> {

    return conn |> writeHeaders(
      [
        ResponseHeader.setSignedCookie(
          key: githubSessionCookieName,
          value: conn.data.right!,
          options: [],
          secret: EnvVars.appSecret,
          encrypt: true
        )
        ] |> catOptionals
    )
}

extension Conn {
  func `throw`<J, B>(_ error: Error) -> Conn<J, Error, B> {
    return .init(
      data: .left(error),
      request: self.request,
      response: self.response
    )
  }
}

/// Exchanges a github code for an access token and loads the user's data.
private func authTokenMiddleware(
  _ conn: Conn<StatusLineOpen, Never, (code: String, redirect: String?)>
  )
  -> IO<Conn<ResponseEnded, Error, Data>> {

    return AppEnvironment.current.fetchAuthToken(conn.data.guaranteedRight.code)
      .flatMap { token in
        AppEnvironment.current.fetchGitHubUser(token)
          .map { user in GitHubUserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .run
      .flatMap { gitHubUserEnvelope in
        switch gitHubUserEnvelope {
        case let .left(error):
          return pure <| conn.throw(error)

        case let .right(env):
          return conn.mapConn(const(Either<Error, GitHubUserEnvelope>.right(env)))
            |> redirect(
              to: conn.data.guaranteedRight.redirect ?? path(to: .secretHome),
              headersMiddleware: writeGitHubSessionCookieMiddleware
          )
        }
    }
}

private let githubAuthorizationUrl =
  "https://github.com/login/oauth/authorize?scope=user:email&client_id=\(EnvVars.GitHub.clientId)"
private func githubAuthorizationUrl(withRedirect redirect: String?) -> String {

  let params: [String: String] = [
    "scope": "user:email",
    "client_id": EnvVars.GitHub.clientId,
    "redirect_uri": url(to: .githubCallback(code: "", redirect: redirect))
  ]

  let query = params.map { key, value in
    "\(key)=" + (value.addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed) ?? "")
    }
    .joined(separator: "&")

  return "https://github.com/login/oauth/authorize?\(query)"
}

private let githubSessionCookieName = "github_session"

extension CharacterSet {
  fileprivate static let urlQueryParamAllowed = CharacterSet(charactersIn: "?=&# ").inverted
}
