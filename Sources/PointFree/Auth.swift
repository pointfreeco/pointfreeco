import CustomDump
import Dependencies
import Either
import EmailAddress
import Foundation
import GitHub
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import PostgresNIO
import Prelude
import Tuple
import UrlFormEncoding

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

let gitHubCallbackResponse =
  requireLoggedOutUser
  <<< requireAuthCodeAndAccessToken
  <| { conn in IO { await gitHubAuthTokenMiddleware(conn) } }

private let requireAuthCodeAndAccessToken:
  MT<Tuple2<String?, String?>, Tuple2<GitHub.AccessToken, String?>> =
    filterMap(require1 >>> pure, or: map(const(unit)) >>> missingGitHubAuthCodeMiddleware)
    <<< requireAccessToken

/// Middleware to run when the GitHub auth code is missing.
private let missingGitHubAuthCodeMiddleware: M<Prelude.Unit> =
  writeStatus(.badRequest)
  >=> respond(text: "GitHub code wasn't found :(")

/// Redirects to GitHub authorization and attaches the redirect specified in the connection data.
let loginResponse: M<String?> =
  requireLoggedOutUser
  <| { $0 |> redirect(to: gitHubAuthorizationUrl(withRedirect: $0.data)) }

func logoutResponse(
  _ conn: Conn<StatusLineOpen, Prelude.Unit>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.siteRouter) var siteRouter

  return conn
    |> redirect(
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

private func requireLoggedOutUser<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

  return { conn in
    @Dependency(\.currentUser) var currentUser
    @Dependency(\.database) var database
    guard currentUser == nil
    else {
      return conn
        |> redirect(to: .account(), headersMiddleware: flash(.warning, "You’re already logged in."))
    }
    return middleware(conn)
  }
}

public func fetchUser<A>(_ conn: Conn<StatusLineOpen, T2<Models.User.ID, A>>)
  -> IO<Conn<StatusLineOpen, T2<Models.User?, A>>>
{
  @Dependency(\.database) var database

  return IO { try? await database.fetchUserById(get1(conn.data)) }
    .map { conn.map(const($0 .*. conn.data.second)) }
}

private func fetchOrRegisterUser(env: GitHubUserEnvelope) async throws -> Models.User {
  @Dependency(\.database) var database

  do {
    return try await database.fetchUserByGitHub(env.gitHubUser.id)
  } catch {
    return try await registerUser(env: env)
  }
}

extension GitHubUser {
  public struct AlreadyRegistered: Error {
    let email: EmailAddress
  }
}

private func registerUser(env: GitHubUserEnvelope) async throws -> Models.User {
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.date.now) var now

  let email = try await gitHub.fetchEmails(env.accessToken).first(where: \.primary).unwrap().email
  do {
    let user = try await database.registerUser(
      withGitHubEnvelope: env,
      email: email,
      now: { now }
    )
    await fireAndForget {
      try await sendEmail(
        to: [email],
        subject: "Point-Free Registration",
        content: inj2(registrationEmailView(env.gitHubUser))
      )
    }
    return user
  } catch let PostgresError.server(error) where error.fields[.constraintName] == "users_email_key" {
    throw GitHubUser.AlreadyRegistered(email: email)
  }
}

/// Exchanges a GitHub code for an access token and loads the user's data.
private func gitHubAuthTokenMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple2<GitHub.AccessToken, String?>>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.siteRouter) var siteRouter

  let (token, redirect) = lower(conn.data)

  do {
    let gitHubUser = try await gitHub.fetchUser(token)
    let env = GitHubUserEnvelope(accessToken: token, gitHubUser: gitHubUser)
    let user = try await fetchOrRegisterUser(env: env)
    try await refreshStripeSubscription(for: user)
    return conn.redirect(to: redirect ?? siteRouter.path(for: .home)) {
      $0.writeSessionCookie { $0.user = .standard(user.id) }
    }
  } catch let error as GitHubUser.AlreadyRegistered {
    return conn.redirect(to: .home) {
      $0.flash(
        .error,
        """
        The primary email address associated with your GitHub account, \(error.email.rawValue), is \
        already registered with Point-Free under a different \
        [GitHub account](https://github.com/settings) account.

        Log into the GitHub account associated with your Point-Free account before trying again, \
        or contact <support@pointfree.co>.
        """
      )
    }
  } catch {
    await fireAndForget {
      try await sendEmail(
        to: adminEmails,
        subject: "GitHub Auth Failed",
        content: inj1(String(customDumping: error))
      )
    }
    return conn.redirect(to: .home) {
      $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
    }
  }
}

private func requireAccessToken<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<GitHub.AccessToken, String?, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T3<String, String?, A>, Data>
{
  @Dependency(\.gitHub) var gitHub

  return { conn in
    let (code, redirect) = (get1(conn.data), get2(conn.data))

    return EitherIO { try await gitHub.fetchAuthToken(code) }
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

private func refreshStripeSubscription(for user: Models.User) async throws {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  guard let subscriptionId = user.subscriptionId else { return }

  let subscription = try await database.fetchSubscriptionById(subscriptionId)
  let stripeSubscription =
    try await stripe
    .fetchSubscription(subscription.stripeSubscriptionId)
  _ = try await database.updateStripeSubscription(stripeSubscription)
}

private func gitHubAuthorizationUrl(withRedirect redirect: String?) -> String {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.envVars.gitHub.clientId) var gitHubClientId

  return GitHubRouter().url(
    for: .authorize(
      clientId: gitHubClientId,
      redirectUri: siteRouter.url(for: .gitHubCallback(code: nil, redirect: redirect)),
      scope: "user:email"
    )
  )
  .absoluteString
}
