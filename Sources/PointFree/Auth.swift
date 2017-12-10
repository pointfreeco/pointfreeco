import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import UrlFormEncoding

let secretHomeResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> readGitHubSessionCookieMiddleware
    >-> respond(secretHomeView)

let gitHubCallbackResponse =
  extractGitHubAuthCode
    <| authTokenMiddleware

/// Middleware transformer to convert the optional GitHub code to a non-optional. In the `nil` case we show
/// a 400 Bad Request page.
private func extractGitHubAuthCode(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, (code: String, redirect: String?), Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, (code: String?, redirect: String?), Data> {
    
    return { conn in
      conn.data.code
        .map { (code: $0, redirect: conn.data.redirect) }
        .map { conn.map(const($0)) }
        .map(middleware)
        ?? (conn |> const(unit) >¢< missingGitHubAuthCodeMiddleware)
    }
}

/// Middleware to run when the GitHub auth code is missing.
private let missingGitHubAuthCodeMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  writeStatus(.badRequest)
    >-> respond(text: "GitHub code wasn't found :(")

/// Redirects to GitHub authorization and attaches the redirect specified in the connection data.
let loginResponse: Middleware<StatusLineOpen, ResponseEnded, String?, Data> =
  { $0 |> redirect(to: gitHubAuthorizationUrl(withRedirect: $0.data)) }

let logoutResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  redirect(
    to: path(to: .secretHome),
    headersMiddleware: writeHeader(.clearCookie(key: gitHubSessionCookieName))
    )

private let secretHomeView = View<Either<Prelude.Unit, GitHub.UserEnvelope>> { data in
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
  -> IO<Conn<HeadersOpen, Either<Prelude.Unit, GitHub.UserEnvelope>>> {

    return pure <| conn.map(
      const(
        conn.request.cookies[gitHubSessionCookieName]
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
  _ conn: Conn<HeadersOpen, GitHub.UserEnvelope>
  )
  -> IO<Conn<HeadersOpen, GitHub.UserEnvelope>> {

    return conn |> writeHeaders(
      [
        ResponseHeader.setSignedCookie(
          key: gitHubSessionCookieName,
          value: conn.data,
          options: [],
          secret: AppEnvironment.current.envVars.appSecret,
          encrypt: true
        )
        ] |> catOptionals
    )
}

/// Exchanges a github code for an access token and loads the user's data.
private func authTokenMiddleware(
  _ conn: Conn<StatusLineOpen, (code: String, redirect: String?)>
  )
  -> IO<Conn<ResponseEnded, Data>> {

    return AppEnvironment.current.gitHub.fetchAuthToken(conn.data.code)
      .flatMap { token in
        AppEnvironment.current.gitHub.fetchUser(token)
          .map { user in GitHub.UserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .flatMap { env in
        // todo: fetch or create aint working
        AppEnvironment.current.database.fetchUser(env.accessToken).bimap(const(unit), const(env))
          <|> AppEnvironment.current.database.createUser(env).bimap(const(unit), const(env))
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

private func gitHubAuthorizationUrl(withRedirect redirect: String?) -> String {
  return gitHubUrl(
    to: .authorize(
      clientId: AppEnvironment.current.envVars.gitHub.clientId,
      redirectUri: url(to: .gitHubCallback(code: nil, redirect: redirect)),
      scope: "user:email"
    )
  )
}

let gitHubSessionCookieName = "github_session"

extension CharacterSet {
  fileprivate static let urlQueryParamAllowed = CharacterSet(charactersIn: "?=&# ").inverted
}
