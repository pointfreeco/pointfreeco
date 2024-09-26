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
import Views

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

func authMiddleware(
  _ conn: Conn<StatusLineOpen, SiteRoute.Auth>
) async -> Conn<ResponseEnded, Data> {
  switch conn.data {
  case let .gitHubAuth(redirect):
    return await loginResponse(conn.map(const(redirect)))
      .performAsync()

  case let .gitHubCallback(code, redirect):
    return await gitHubCallbackResponse(conn.map(const(code .*. redirect .*. unit)))
      .performAsync()

  case .gitHubFailureLanding(code: let code, redirect: let redirect):
    return await gitHubFailureLanding(code: code, redirect: redirect, conn.map { _ in () })

  case let .login(redirect):
    return await loginSignUpMiddleware(
      redirect: redirect,
      type: .login,
      conn.map(const(()))
    )

  case .logout:
    return await logoutResponse(conn.map(const(unit)))
      .performAsync()

  case .overrideGitHubAccount(code: let code, redirect: let redirect):
    return await overrideGitHubAccount(code: code, redirect: redirect, conn.map { _ in () })

  case let .signUp(redirect):
    return await loginSignUpMiddleware(
      redirect: redirect,
      type: .signUp,
      conn.map(const(()))
    )
  }
}

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
    self.redirect(to: .gitHubAuth(redirect: self.request.url?.absoluteString))
  }
}

public func loginAndRedirect<A>(_ conn: Conn<StatusLineOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  conn |> redirect(to: .gitHubAuth(redirect: conn.request.url?.absoluteString))
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

  return IO { try? await database.fetchUser(id: get1(conn.data)) }
    .map { conn.map(const($0 .*. conn.data.second)) }
}

private func fetchOrRegisterUser(env: GitHubUserEnvelope) async throws -> Models.User {
  @Dependency(\.database) var database

  do {
    let user = try await database.fetchUser(gitHubID: env.gitHubUser.id)
    return user
  } catch {
    return try await registerUser(env: env)
  }
}

extension GitHubUser {
  public struct AlreadyRegistered: Error {
    let email: EmailAddress
  }
  public struct InvalidCode: Error {}
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
  } catch let error as PSQLError
    where
    error.serverInfo?[.constraintName] == "users_email_key"
    && error.serverInfo?[.routine] == "_bt_check_unique"
  {
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
    return conn.redirect(to: .auth(.gitHubFailureLanding(code: code, redirect: redirect)))
//    {
//      $0.flash(
//        .error,
//        """
//        The primary email address associated with your GitHub account, \(error.email.rawValue), is \
//        already registered with Point-Free under a different \
//        [GitHub account](https://github.com/settings) account.
//
//        Log into the GitHub account associated with your Point-Free account before trying again, \
//        or contact <support@pointfree.co>.
//        """
//      )
//    }
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
          return conn |> PointFree.redirect(to: .gitHubAuth(redirect: redirect))
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

private func accessToken(code: String) async throws -> AccessToken {
  @Dependency(\.gitHub) var gitHub
  return try await gitHub.fetchAuthToken(code: code).either(
    { _ in throw GitHubUser.InvalidCode() },
    { $0 }
  )
}

private func refreshStripeSubscription(for user: Models.User) async throws {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  guard let subscriptionId = user.subscriptionId else { return }

  let subscription = try await database.fetchSubscription(id: subscriptionId)
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

private func gitHubFailureLanding(
  code: String,
  redirect: String?,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.gitHub) var gitHub

  do {
    let accessToken = try await accessToken(code: code)
    async let gitHubUser = gitHub.fetchUser(accessToken)
    async let email = gitHub.fetchEmails(accessToken).first(where: \.primary).unwrap().email
    let existingUser = try await database.fetchUser(email: email)
    return conn
      .writeStatus(.ok)
      .respondV2(
        layoutData: SimplePageLayoutData(
          title: "Update your GitHub account?"
        )
      ) {
        GitHubFailureView()
        }

//        """
//        The primary email address associated with your GitHub account, \(error.email.rawValue), is \
//        already registered with Point-Free under a different \
//        [GitHub account](https://github.com/settings) account.
//        
//        Log into the GitHub account associated with your Point-Free account before trying again, \
//        or contact <support@pointfree.co>.
//        """
//    let user = database.fetchUser

//    let user = try await fetchOrRegisterUser(env: env)
//    try await refreshStripeSubscription(for: user)
//    return conn.redirect(to: redirect ?? siteRouter.path(for: .home)) {
//      $0.writeSessionCookie { $0.user = .standard(user.id) }
//    }
  } catch {
    fatalError()
  }
}

private func overrideGitHubAccount(
  code: String,
  redirect: String?,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  fatalError()
}
