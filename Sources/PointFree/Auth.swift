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
import Tuple

let gitHubCallbackResponse =
  extractGitHubAuthCode
    <| gitHubAuthTokenMiddleware

/// Middleware transformer to convert the optional GitHub code to a non-optional. In the `nil` case we show
/// a 400 Bad Request page.
private func extractGitHubAuthCode(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, (code: String, redirect: String?), Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, (code: String?, redirect: String?), Data> {

    return { conn in
      conn.data.code
        .map { (code: $0, redirect: conn.data.redirect) }
        .map(conn.map <<< const)
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
    headersMiddleware: writeSessionCookieMiddleware(\.userId .~ nil)
)

public func loginAndRedirect<A>(_ conn: Conn<StatusLineOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  return conn
    |> redirect(to: .login(redirect: conn.request.url?.absoluteString))
}

public func currentUserMiddleware<A>(_ conn: Conn<StatusLineOpen, A>)
  -> IO<Conn<StatusLineOpen, T2<Database.User?, A>>> {

    let user = conn.request.session.userId
      .flatMap {
        AppEnvironment.current.database.fetchUserById($0)
          .run
          .map(either(const(nil), id))
      }
      ?? pure(nil)

    return user.map { conn.map(const($0 .*. conn.data)) }
}

public func fetchUser<A>(_ conn: Conn<StatusLineOpen, T2<Database.User.Id, A>>)
  -> IO<Conn<StatusLineOpen, T2<Database.User?, A>>> {

    return AppEnvironment.current.database.fetchUserById(get1(conn.data))
      .run
      .map { conn.map(const($0.right.flatMap(id) .*. conn.data.second)) }
}

private func fetchOrRegisterUser(env: GitHub.UserEnvelope) -> EitherIO<Prelude.Unit, Database.User> {

  return AppEnvironment.current.database.fetchUserByGitHub(env.gitHubUser.id)
    .flatMap { user in user.map(pure) ?? registerUser(env: env) }
    .withExcept(const(unit))
}

private func registerUser(env: GitHub.UserEnvelope) -> EitherIO<Error, Database.User> {

  return AppEnvironment.current.database.registerUser(env)
    .mapExcept(requireSome)
    .flatMap { user in
      EitherIO(run: IO { () -> Either<Error, Database.User> in

        // Fire-and-forget notify user that they signed up
        parallel(
          sendEmail(
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
private func gitHubAuthTokenMiddleware(
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
              headersMiddleware: writeSessionCookieMiddleware(\.userId .~ user.id)
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
