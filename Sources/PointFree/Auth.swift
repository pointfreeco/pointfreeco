import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude

let secretHomeResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> readGitHubSessionCookieMiddleware
    >-> respond(secretHomeView)


let githubCallbackResponse =
  authTokenMiddleware

/// Redirects to GitHub authorization and attaches the redirect specified in the connection data.
let loginResponse: Middleware<StatusLineOpen, ResponseEnded, String?, Data> =
  { $0 |> redirect(to: gitHubAuthorizationUrl(withRedirect: $0.data)) }

let logoutResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  redirect(
    to: path(to: .secretHome),
    headersMiddleware: writeHeader(.clearCookie(key: githubSessionCookieName))
    )

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
  _ conn: Conn<HeadersOpen, Prelude.Unit>
  )
  -> IO<Conn<HeadersOpen, Either<Prelude.Unit, GitHubUserEnvelope>>> {

    return pure <| conn.map(
      const(
        conn.request.cookies[githubSessionCookieName]
          .flatMap { ResponseHeader.verifiedValue(signedCookieValue: $0, secret: EnvVars.appSecret) }
          .map(Either.right)
          ?? .left(unit)
      )
    )
}

private func writeGitHubSessionCookieMiddleware(
  _ conn: Conn<HeadersOpen, GitHubUserEnvelope>
  )
  -> IO<Conn<HeadersOpen, GitHubUserEnvelope>> {

    return conn |> writeHeaders(
      [
        ResponseHeader.setSignedCookie(
          key: githubSessionCookieName,
          value: conn.data,
          options: [],
          secret: EnvVars.appSecret,
          encrypt: true
        )
        ] |> catOptionals
    )
}

/// Exchanges a github code for an access token and loads the user's data.
private func authTokenMiddleware(
  _ conn: Conn<StatusLineOpen, (code: String, redirect: String?)>
  )
  -> IO<Conn<ResponseEnded, Either<Error, Data>>> {

    return AppEnvironment.current.fetchAuthToken(conn.data.code)
      .flatMap { token in
        AppEnvironment.current.fetchGitHubUser(token)
          .map { user in GitHubUserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .run
      .flatMap { gitHubUserEnvelope in

        switch gitHubUserEnvelope {
        case let .left(error):
          return conn.map(const(Either<Error, Data>.left(error)))
            |> writeStatus(.internalServerError)
            >-> end
            >>> map(map(const(.left(error))))
        case let .right(env):
          return conn.map(const(env))
            |> redirect(
              to: conn.data.redirect ?? path(to: .secretHome),
              headersMiddleware: writeGitHubSessionCookieMiddleware
            )
            >>> map(map(pure))
        }
    }
}

private func gitHubAuthorizationUrl(withRedirect redirect: String?) -> String {

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
