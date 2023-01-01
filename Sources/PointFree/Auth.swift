import Dependencies
import Either
import Foundation
import GitHub
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import UrlFormEncoding

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

let gitHubCallbackResponse =
  requireLoggedOutUser
  <<< requireAuthCodeAndAccessToken
  <| gitHubAuthTokenMiddleware

private let requireAuthCodeAndAccessToken:
  MT<Tuple2<String?, String?>, Tuple2<GitHub.AccessToken, String?>> =
    filterMap(require1 >>> pure, or: map(const(unit)) >>> missingGitHubAuthCodeMiddleware)
    <<< requireAccessToken

/// Middleware to run when the GitHub auth code is missing.
private let missingGitHubAuthCodeMiddleware: M<Prelude.Unit> =
  writeStatus(.badRequest)
  >=> respond(text: "GitHub code wasn't found :(")

/// Redirects to GitHub authorization and attaches the redirect specified in the connection data.
let loginResponse: M<Tuple2<Models.User?, String?>> =
  requireLoggedOutUser
  <| { $0 |> redirect(to: gitHubAuthorizationUrl(withRedirect: get1($0.data))) }

func logoutResponse(
  _ conn: Conn<StatusLineOpen, Prelude.Unit>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.siteRouter) var siteRouter

  return conn |> redirect(
    to: siteRouter.path(for: .home),
    headersMiddleware: writeSessionCookieMiddleware { $0.user = nil }
  )
}

extension Conn where Step == StatusLineOpen {
  public func loginAndRedirect() -> Conn<ResponseEnded, Data> {
    self.redirect(to: .login(redirect: self.request.url?.absoluteString))
  }
}

public func loginAndRedirect<A>(_ conn: Conn<StatusLineOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  conn |> redirect(to: .login(redirect: conn.request.url?.absoluteString))
}

public func currentUserMiddleware<A>(_ conn: Conn<StatusLineOpen, A>)
  -> IO<Conn<StatusLineOpen, T2<Models.User?, A>>>
{
  let user = IO<Models.User?> {
    guard let userId = conn.request.session.userId else { return nil }
    Task { try await Current.database.sawUser(userId) }
    return try? await Current.database.fetchUserById(userId)
  }

  return user.map { conn.map(const($0 .*. conn.data)) }
}

public func requireLoggedOutUser<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, T2<Models.User?, A>, Data> {

  return { conn in
    return conn.map(const(conn.data.second))
      |> (get1(conn.data) == nil
        ? middleware
        : redirect(to: .account(), headersMiddleware: flash(.warning, "You’re already logged in.")))
  }
}

public func currentSubscriptionMiddleware<A, I>(
  _ conn: Conn<I, T2<Models.User?, A>>
) -> IO<Conn<I, T3<(Models.Subscription, EnterpriseAccount?)?, Models.User?, A>>> {

  let user = conn.data.first

  return EitherIO {
    let subscription = try await Current.database.fetchSubscription(user: user.unwrap())

    let enterpriseAccount = try? await Current.database
      .fetchEnterpriseAccountForSubscription(subscription.id)

    return (subscription, enterpriseAccount)
  }
  .run
  .map(\.right)
  .map { conn.map(const($0 .*. conn.data)) }
}

public func fetchUser<A>(_ conn: Conn<StatusLineOpen, T2<Models.User.ID, A>>)
  -> IO<Conn<StatusLineOpen, T2<Models.User?, A>>>
{

  return IO { try? await Current.database.fetchUserById(get1(conn.data)) }
    .map { conn.map(const($0 .*. conn.data.second)) }
}

private func fetchOrRegisterUser(env: GitHubUserEnvelope) -> EitherIO<Error, Models.User> {

  return EitherIO {
    do {
      return try await Current.database.fetchUserByGitHub(env.gitHubUser.id)
    } catch {
      return try await registerUser(env: env).performAsync()
    }
  }
}

private func registerUser(env: GitHubUserEnvelope) -> EitherIO<Error, Models.User> {

  return EitherIO { try await Current.gitHub.fetchEmails(env.accessToken) }
    .map { emails in emails.first(where: \.primary) }
    .mapExcept(requireSome)  // todo: better error messaging
    .flatMap { email in

      EitherIO {
        try await Current.database.registerUser(
          withGitHubEnvelope: env,
          email: email.email,
          now: { Current.date() }
        )
      }
      .flatMap { user in
        EitherIO(
          run: IO { () -> Either<Error, Models.User> in

            // Fire-and-forget notify user that they signed up
            Task {
              _ = try await sendEmail(
                to: [email.email],
                subject: "Point-Free Registration",
                content: inj2(registrationEmailView(env.gitHubUser))
              )
            }

            return .right(user)
          })
      }
    }
}

/// Exchanges a github code for an access token and loads the user's data.
private func gitHubAuthTokenMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple2<GitHub.AccessToken, String?>>
)
  -> IO<Conn<ResponseEnded, Data>>
{
  @Dependency(\.siteRouter) var siteRouter

  let (token, redirect) = lower(conn.data)

  return EitherIO { try await Current.gitHub.fetchUser(token) }
    .map { user in GitHubUserEnvelope(accessToken: token, gitHubUser: user) }
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
          conn
            |> PointFree.redirect(
              to: .home,
              headersMiddleware: flash(
                .error,
                "We were not able to log you in with GitHub. Please try again."
              )
            )
        )
      ) { user in
        conn
          |> HttpPipeline.redirect(
            to: redirect ?? siteRouter.path(for: .home),
            headersMiddleware: writeSessionCookieMiddleware { $0.user = .standard(user.id) }
          )
      }
    )
}

private func requireAccessToken<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<GitHub.AccessToken, String?, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T3<String, String?, A>, Data>
{

  return { conn in
    let (code, redirect) = (get1(conn.data), get2(conn.data))

    return EitherIO { try await Current.gitHub.fetchAuthToken(code) }
      .run
      .flatMap { errorOrToken in
        switch errorOrToken {
        case let .right(.right(token)):
          return conn.map(const(token .*. conn.data.second)) |> middleware
        case let .right(.left(error)) where error.error == .badVerificationCode:
          return conn |> PointFree.redirect(to: .login(redirect: redirect))
        case .right(.left), .left:
          return conn
            |> PointFree.redirect(
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

private func refreshStripeSubscription(for user: Models.User) -> EitherIO<Error, Prelude.Unit> {
  guard let subscriptionId = user.subscriptionId else { return pure(unit) }

  return EitherIO {
    let subscription = try await Current.database.fetchSubscriptionById(subscriptionId)
    let stripeSubscription = try await Current.stripe
      .fetchSubscription(subscription.stripeSubscriptionId)
    _ = try await Current.database.updateStripeSubscription(stripeSubscription)
    return unit
  }
}

private func gitHubAuthorizationUrl(withRedirect redirect: String?) -> String {
  @Dependency(\.siteRouter) var siteRouter
  
  return gitHubRouter.url(
    for: .authorize(
      clientId: Current.envVars.gitHub.clientId,
      redirectUri: siteRouter.url(for: .gitHubCallback(code: nil, redirect: redirect)),
      scope: "user:email"
    )
  )
  .absoluteString
}
