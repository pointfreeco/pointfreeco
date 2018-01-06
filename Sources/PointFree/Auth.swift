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
  filterMap(require1 >>> pure, or: map(const(unit)) >>> missingGitHubAuthCodeMiddleware)
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

public func currentSubscriptionMiddleware<A, I>(
  _ conn: Conn<I, T2<Database.User?, A>>
  ) -> IO<Conn<I, T3<Database.Subscription?, Database.User?, A>>> {

  return conn.data.first
    .map { user in
      guard let subscriptionId = user.subscriptionId
        else { return pure(conn.map(const(nil .*. conn.data))) }

      return AppEnvironment.current.database.fetchSubscriptionById(subscriptionId)
        .mapExcept(requireSome)
        .run
        .map(^\.right)
        .map { conn.map(const($0 .*. conn.data)) }
    }
    ?? pure(conn.map(const(nil .*. conn.data)))
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
        refreshStripeSubscription(for: user)
          .map(const(user))
      }
      .run
      .flatMap { errorOrUser in
        switch errorOrUser {
        case .left:
          return conn
            // TODO: Handle errors.
            |> PointFree.redirect(
              to: .secretHome,
              headersMiddleware: flash(.error, "We were not able to log you in with GitHub. Please try again.")
          )

        case let .right(user):
          return conn.map(const(user))
            |> HttpPipeline.redirect(
              to: redirect ?? path(to: .secretHome),
              headersMiddleware: writeSessionCookieMiddleware(\.userId .~ user.id)
          )
        }
    }
}

private func refreshStripeSubscription(for user: Database.User) -> EitherIO<Prelude.Unit, Prelude.Unit> {
  guard let subscriptionId = user.subscriptionId else { return pure(unit) }

  return AppEnvironment.current.database.fetchSubscriptionById(subscriptionId)
    .mapExcept(requireSome)
    .flatMap { subscription in
      AppEnvironment.current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
        .bimap(const(unit as Error), id)
        .flatMap { stripeSubscription in
          AppEnvironment.current.database.updateSubscription(subscription, stripeSubscription)
        }
    }
    .bimap(const(unit), id)
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
