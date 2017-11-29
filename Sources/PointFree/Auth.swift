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
  { $0 |> redirect(to: githubAuthorizationUrl(withRedirect: $0.data)) }

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

    a(
      [href(path(to: .episodes(tag: nil)))],
      ["Episodes"]
    ),

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
          .flatMap {
            ResponseHeader
              .verifiedValue(signedCookieValue: $0, secret: AppEnvironment.current.envVars.appSecret)
          }
          .map(Either.right)
          ?? Either.left(unit)
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
          secret: AppEnvironment.current.envVars.appSecret,
          encrypt: true
        )
        ] |> catOptionals
    )
}

// TODO: Move to Prelude.
extension EitherIO {
  public func bimap<F, B>(_ f: @escaping (E) -> F, _ g: @escaping (A) -> B) -> EitherIO<F, B> {
    return .init(run: self.run.map { $0.bimap(f, g) })
  }
}

/// Exchanges a github code for an access token and loads the user's data.
private func authTokenMiddleware(
  _ conn: Conn<StatusLineOpen, (code: String, redirect: String?)>
  )
  -> IO<Conn<ResponseEnded, Data>> {

    return AppEnvironment.current.fetchAuthToken(conn.data.code)
      .flatMap { token in
        AppEnvironment.current.fetchGitHubUser(token)
          .map { user in GitHubUserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .flatMap { env in
        // uncomment to keep from hitting DB
//        .init(run: .init({ .right(env) }))

        AppEnvironment.current.fetchUser(env.accessToken).bimap(const(unit), const(env))
          <|> AppEnvironment.current.createUser(env).bimap(const(unit), const(env))
      }
      .run
      .flatMap { gitHubUserEnvelope in
        switch gitHubUserEnvelope {

        case .left:
          return conn
            // TODO: Handle errors.
            |> redirect(to: path(to: .secretHome))

        case let .right(env):
          return conn.map(const(env))
            |> redirect(
              to: conn.data.redirect ?? path(to: .secretHome),
              headersMiddleware: writeGitHubSessionCookieMiddleware
          )
        }
    }
}

private let githubAuthorizationUrl =
  "https://github.com/login/oauth/authorize?scope=user:email&client_id="
    + AppEnvironment.current.envVars.gitHub.clientId
private func githubAuthorizationUrl(withRedirect redirect: String?) -> String {

  let params: [String: String] = [
    "scope": "user:email",
    "client_id": AppEnvironment.current.envVars.gitHub.clientId,
    "redirect_uri": url(to: .githubCallback(code: "", redirect: redirect))
  ]

  return "https://github.com/login/oauth/authorize?\(urlFormEncode(value: params))"
}

private let githubSessionCookieName = "github_session"

extension CharacterSet {
  fileprivate static let urlQueryParamAllowed = CharacterSet(charactersIn: "?=&# ").inverted
}
