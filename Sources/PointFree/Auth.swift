import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import UrlFormEncoding

let secretHomeResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> readGitHubSessionCookieMiddleware
    >-> (ignoreErrors >>> pure)
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
    headersMiddleware: writeHeader(.clearCookie(key: pointFreeUserSession))
    )

private let secretHomeView = View<Database.User?> { user in
  [
    p(["welcome home"]),

    p([
      text(
        user.map { "You are logged in as \($0.name)" }
          ?? "You are not logged in"
      )
      ]),

    a(
      [href(path(to: .episodes(tag: nil)))],
      ["Episodes"]
    ),

    p([
       user != nil
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
  -> IO<Conn<HeadersOpen, Either<Error, Database.User>>> {

    return (
      conn.request.cookies[pointFreeUserSession]
        .flatMap {
          ResponseHeader
            .verifiedString(signedCookieValue: $0, secret: AppEnvironment.current.envVars.appSecret)
        }
        .flatMap(UUID.init(uuidString:))
        .map {
          AppEnvironment.current.database.fetchUserById($0)
            .mapExcept(requireSome)
        }
        ?? throwE(unit)
      )
      .run
      .map { conn.map(const($0)) }
}

private func writeGitHubSessionCookieMiddleware(
  _ conn: Conn<HeadersOpen, Database.User>
  )
  -> IO<Conn<HeadersOpen, Database.User>> {

    return conn |> writeHeaders(
      [
        ResponseHeader.setSignedCookie(
          key: pointFreeUserSession,
          value: conn.data.id.uuidString,
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

private func fetchOrRegisterUser(env: GitHub.UserEnvelope) -> EitherIO<Prelude.Unit, Database.User> {

  return AppEnvironment.current.database.fetchUserByGitHub(env.accessToken)
    .flatMap { user in
      EitherIO(run: IO { user.map(Either.right) ?? .left(unit) })
        .catch(const(registerUser(env: env)))
    }
    .mapExcept(bimap(const(unit), id))
}

private func registerUser(env: GitHub.UserEnvelope) -> EitherIO<Error, Database.User> {

  return AppEnvironment.current.database.upsertUser(env)
    .mapExcept(requireSome)
    .flatMap { user in
      EitherIO(run: IO { () -> Either<Error, Database.User> in

        // Fire-and-forget notify user that they signed up
        parallel(
          sendEmail(
            from: "Point-Free <support@pointfree.co>",
            to: [env.gitHubUser.email],
            subject: "Point-Free Registration",
            content: inj2(registrationEmailView.view(env.gitHubUser))
            )
            .run
          )
          .run({ _ in })

        return .right(user)
      })
  }
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
      .flatMap(fetchOrRegisterUser(env:))
      .run
      .flatMap {
        switch $0 {
        case .left:
          return conn
            // TODO: Handle errors.
            |> redirect(to: path(to: .secretHome))

        case let .right(user):
          return conn.map(const(user))
            |> redirect(
              to: conn.data.redirect ?? path(to: .secretHome),
              headersMiddleware: writeGitHubSessionCookieMiddleware
          )
        }
    }
}

private func gitHubAuthorizationUrl(withRedirect redirect: String?) -> String {

  let params: [(String, String)] = [
    ("scope", "user:email"),
    ("client_id", AppEnvironment.current.envVars.gitHub.clientId),
    ("redirect_uri", url(to: .gitHubCallback(code: nil, redirect: redirect)))
  ]

  let queryString = params
    .map { key, value in
      key + "=" + (value.addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed) ?? "")
    }
    .joined(separator: "&")

  return "https://github.com/login/oauth/authorize?\(queryString)"
}

let pointFreeUserSession = "pf_session"

extension CharacterSet {
  fileprivate static let urlQueryParamAllowed = CharacterSet(charactersIn: "?=&# ").inverted
}

let registrationEmailView = View<GitHub.User> { _ in
  document([
    html([
      head([
        style(styleguide),
        ]),

      body([
        gridRow([
          gridColumn(sizes: [:], [
            div([`class`([Class.padding.all(2)])], [
              h3([`class`([Class.h3])], ["Thanks for signing up!"]),
              p([`class`([Class.padding.topBottom(2)])], [
                "You’re one step closer to our weekly video series!",
                ])
              ])
            ])
          ])
        ])
      ])
    ])
}
