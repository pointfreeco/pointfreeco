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
  requireLoggedOutUser
    <<< filterMap(require1 >>> pure, or: map(const(unit)) >>> missingGitHubAuthCodeMiddleware)
    <<< requireAccessToken
    <| gitHubAuthTokenMiddleware

/// Middleware to run when the GitHub auth code is missing.
private let missingGitHubAuthCodeMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  writeStatus(.badRequest)
    >=> respond(text: "GitHub code wasn't found :(")

/// Redirects to GitHub authorization and attaches the redirect specified in the connection data.
let loginResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User?, String?>, Data> =
  requireLoggedOutUser
    <| { $0 |> redirect(to: gitHubAuthorizationUrl(withRedirect: get1($0.data))) }

let logoutResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  redirect(
    to: path(to: .home),
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
        Current.database.fetchUserById($0)
          .run
          .map(either(const(nil), id))
      }
      ?? pure(nil)

    return user.map { conn.map(const($0 .*. conn.data)) }
}

public func requireLoggedOutUser<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data> {

  return { conn in
    return conn.map(const(conn.data.second))
      |> (
        get1(conn.data) == nil
          ? middleware
          : redirect(to: .account(.index), headersMiddleware: flash(.warning, "You’re already logged in."))
    )
  }
}

public func currentSubscriptionMiddleware<A, I>(
  _ conn: Conn<I, T2<Database.User?, A>>
  ) -> IO<Conn<I, T3<Database.Subscription?, Database.User?, A>>> {

  let user = conn.data.first

  let userSubscription = (user?.subscriptionId)
    .map(
      Current.database.fetchSubscriptionById
        >>> mapExcept(requireSome)
    )
    ?? throwE(unit)

  let ownerSubscription = (user?.id)
    .map(
      Current.database.fetchSubscriptionByOwnerId
        >>> mapExcept(requireSome)
    )
    ?? throwE(unit)

  return (userSubscription.run.parallel <|> ownerSubscription.run.parallel)
    .sequential
    .map(^\.right)
    .map { conn.map(const($0 .*. conn.data)) }
}

public func fetchUser<A>(_ conn: Conn<StatusLineOpen, T2<Database.User.Id, A>>)
  -> IO<Conn<StatusLineOpen, T2<Database.User?, A>>> {

    return Current.database.fetchUserById(get1(conn.data))
      .run
      .map { conn.map(const($0.right.flatMap(id) .*. conn.data.second)) }
}

private func fetchOrRegisterUser(env: GitHub.UserEnvelope) -> EitherIO<Error, Database.User> {

  return Current.database.fetchUserByGitHub(env.gitHubUser.id)
    .flatMap { user in user.map(pure) ?? registerUser(env: env) }
}

private func registerUser(env: GitHub.UserEnvelope) -> EitherIO<Error, Database.User> {

  return Current.gitHub.fetchEmails(env.accessToken)
    .map { emails in emails.first(where: { $0.primary }) }
    .mapExcept(requireSome) // todo: better error messaging
    .flatMap { email in

      Current.database.registerUser(env, email.email)
        .mapExcept(requireSome)
        .flatMap { user in
          EitherIO(run: IO { () -> Either<Error, Database.User> in

            // Fire-and-forget notify user that they signed up
            parallel(
              sendEmail(
                to: [email.email],
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
}

/// Exchanges a github code for an access token and loads the user's data.
private func gitHubAuthTokenMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple2<GitHub.AccessToken, String?>>
  )
  -> IO<Conn<ResponseEnded, Data>> {
    let (token, redirect) = lower(conn.data)

    return Current.gitHub.fetchUser(token)
      .map { user in GitHub.UserEnvelope(accessToken: token, gitHubUser: user) }
      .flatMap(fetchOrRegisterUser(env:))
      .flatMap { user in
        refreshStripeSubscription(for: user)
          .map(const(user))
      }
      .withExcept(notifyError(subject: "GitHub Auth Failed"))
      .run
      .flatMap(
        either(
          const(
            conn |> PointFree.redirect(
              to: .home,
              headersMiddleware: flash(
                .error,
                "We were not able to log you in with GitHub. Please try again."
              )
            )
          )
        ) { user in
          conn |> HttpPipeline.redirect(
            to: redirect ?? path(to: .home),
            headersMiddleware: writeSessionCookieMiddleware(\.userId .~ user.id)
          )
        }
    )
}

private func requireAccessToken<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<GitHub.AccessToken, String?, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<String, String?, A>, Data> {

    return { conn in
      let (code, redirect) = (get1(conn.data), get2(conn.data))

      return Current.gitHub.fetchAuthToken(code)
        .run
        .flatMap { errorOrToken in
          switch errorOrToken {
          case let .right(.right(token)):
            return conn.map(const(token .*. conn.data.second)) |> middleware
          case let .right(.left(error)) where error.error == .badVerificationCode:
            return conn |> PointFree.redirect(to: .login(redirect: redirect))
          case .right(.left), .left:
            return conn |> PointFree.redirect(
              to: .home,
              headersMiddleware: flash(
                .error,
                "We were not able to log you in with GitHub. Please try again."
              )
            )
          }
      }
    }
}

private func refreshStripeSubscription(for user: Database.User) -> EitherIO<Error, Prelude.Unit> {
  guard let subscriptionId = user.subscriptionId else { return pure(unit) }

  return Current.database.fetchSubscriptionById(subscriptionId)
    .mapExcept(requireSome)
    .flatMap { subscription in
      Current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
        .flatMap { stripeSubscription in
          Current.database.updateStripeSubscription(stripeSubscription)
            .map(const(unit)) // FIXME: mapExcept(requireSome) / handle failure?
        }
    }
}

private func gitHubAuthorizationUrl(withRedirect redirect: String?) -> String {
  return gitHubUrl(
    to: .authorize(
      clientId: Current.envVars.gitHub.clientId,
      redirectUri: url(to: .gitHubCallback(code: nil, redirect: redirect)),
      scope: "user:email"
    )
  )
}
