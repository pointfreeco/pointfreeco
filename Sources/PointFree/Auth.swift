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
  filterMap(require1 >>> pure, or: const(unit) >¢< missingGitHubAuthCodeMiddleware)
    <| gitHubAuthTokenMiddleware

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
  _ conn: Conn<StatusLineOpen, Tuple2<String, String?>>
  )
  -> IO<Conn<ResponseEnded, Data>> {
    let (code, redirect) = lower(conn.data)

    return AppEnvironment.current.gitHub.fetchAuthToken(code)
      .flatMap { token in
        AppEnvironment.current.gitHub.fetchUser(token)
          .map { user in GitHub.UserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .flatMap(fetchOrRegisterUser(env:))
      .flatMap { user in
        fetchStripeSubscription(for: user)
          .map { (user, $0) }
      }
      .run
      .flatMap { errorOrData in
        switch errorOrData {
        case .left:
          return conn
            // TODO: Handle errors.
            |> PointFree.redirect(
              to: .secretHome,
              headersMiddleware: flash(.error, "We were not able to log you in with GitHub. Please try again.")
          )

        case let .right(user, subscription):
          return conn.map(const(user))
            |> HttpPipeline.redirect(
              to: redirect ?? path(to: .secretHome),
              headersMiddleware: writeSessionCookieMiddleware(
                ((\Session.userId) .~ user.id)
                  <> (\.subscriptionStatus .~ subscription?.status)
              )
          )
        }
    }
}

private func fetchStripeSubscription(for user: Database.User) -> EitherIO<Prelude.Unit, Stripe.Subscription?> {

  return user.subscriptionId
    .map {
      AppEnvironment.current.database.fetchSubscriptionById($0)
        .bimap(const(unit), id)
        .flatMap { optionalSubscription in
          optionalSubscription.map {
            AppEnvironment.current.stripe.fetchSubscription($0.stripeSubscriptionId)
              .map(Optional.some)
            }
            ?? pure(nil)
      }
    }
    ?? pure(nil)
}

//  if let subscriptionId = currentUser?.subscriptionId {
//    return AppEnvironment.current.database.fetchSubscriptionById(subscriptionId)
//      .map(map(^\.stripeSubscriptionId))
//      .mapExcept(requireSome)
//      .flatMap {
//        AppEnvironment.current.stripe.fetchSubscription($0)
//          .bimap(const(unit as Error), id)
//      }
//      .map(^\.status)
//      .run
//      .map(^\.right)
//      .map { conn.map(const($0 .*. conn.data)) }
//  }


private func gitHubAuthorizationUrl(withRedirect redirect: String?) -> String {
  return gitHubUrl(
    to: .authorize(
      clientId: AppEnvironment.current.envVars.gitHub.clientId,
      redirectUri: url(to: .gitHubCallback(code: nil, redirect: redirect)),
      scope: "user:email"
    )
  )
}
