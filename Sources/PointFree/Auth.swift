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
  case .failureLanding(accessToken: let accessToken, redirect: let redirect):
    return await failureLanding(
      accessToken: accessToken,
      redirect: redirect,
      conn: conn.map(const(()))
    )

  case let .gitHubAuth(redirect):
    return await loginResponse(redirect: redirect, conn: conn.map(const(())))

  case let .gitHubCallback(code, redirect):
    return await gitHubCallbackResponse(code: code, redirect: redirect, conn.map(const(())))

  case let .login(redirect):
    return await loginSignUpMiddleware(
      redirect: redirect,
      type: .login,
      conn.map(const(()))
    )

  case .logout:
    return await logoutResponse(conn.map(const(())))

  case let .signUp(redirect):
    return await loginSignUpMiddleware(
      redirect: redirect,
      type: .signUp,
      conn.map(const(()))
    )
  }
}

private func failureLanding(
  accessToken: AccessToken,
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.gitHub) var gitHub

  do {
    let email = try await gitHub.fetchEmails(accessToken).first(where: \.primary).unwrap().email
    let newGitHubUser = try await gitHub.fetchUser(accessToken: accessToken)
    let existingUser = try await database.fetchUser(email: email)
    let existingGitHubUser = try await gitHub.fetchUser(
      id: existingUser.gitHubUserId,
      accessToken: accessToken
    )
    return conn
      .writeStatus(.ok)
      .respondV2(
        layoutData: SimplePageLayoutData(
          title: "GitHub login"
        )
      ) {
        GitHubFailureView(
          accessToken: accessToken,
          email: email,
          existingGitHubUser: existingGitHubUser,
          newGitHubUser: newGitHubUser,
          redirect: redirect
        )
      }
  } catch {
    return conn
      .redirect(to: .home) {
        $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
      }
  }
}

private func gitHubCallbackResponse(
  code: String?,
  redirect: String?,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.gitHub) var gitHub

  guard currentUser == nil
  else {
    return conn
      .redirect(to: .account()) {
        $0.flash(.warning, "You’re already logged in.")
      }
  }
  guard let code
  else {
    return conn
      .redirect(to: .auth(.login(redirect: nil))) {
        $0.flash(.warning, "GitHub code wasn't found :(")
      }
  }
  do {
    let accessToken = try await gitHub.fetchAuthToken(code: code)
    return await gitHubAuthTokenMiddleware(
      code: code,
      accessToken: accessToken,
      redirect: redirect,
      conn
    )
  } catch let error as OAuthError where error.error == .badVerificationCode {
    return await conn
      .redirect(to: .auth(.gitHubAuth(redirect: redirect)))
  } catch {
    return conn
      .redirect(to: .home) {
        $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
      }
  }
}

private func loginResponse(
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.envVars.gitHub.clientId) var gitHubClientId

  guard currentUser == nil
  else {
    return conn
      .redirect(to: .account()) {
        $0.flash(.warning, "You’re already logged in.")
      }
  }

  let url = GitHubRouter().url(
    for: .authorize(
      clientId: gitHubClientId,
      redirectUri: siteRouter.url(for: .auth(.gitHubCallback(code: nil, redirect: redirect))),
      scope: "user:email"
    )
  )
  .absoluteString

  return await conn
    .redirect(to: url)
}

private func logoutResponse(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  conn
    .redirect(to: .home) {
      $0.writeSessionCookie { $0.user = nil }
    }
}

extension Conn where Step == StatusLineOpen {
  public func loginAndRedirect() -> Conn<ResponseEnded, Data> {
    self.redirect(to: .auth(.gitHubAuth(redirect: self.request.url?.absoluteString)))
  }
}

public func loginAndRedirect<A>(_ conn: Conn<StatusLineOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  conn |> redirect(to: .auth(.gitHubAuth(redirect: conn.request.url?.absoluteString)))
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
    return try await database.fetchUser(gitHubID: env.gitHubUser.id)
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
  code: String,
  accessToken: GitHub.AccessToken,
  redirect: String?,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.siteRouter) var siteRouter

  do {
    let gitHubUser = try await gitHub.fetchUser(accessToken)
    let env = GitHubUserEnvelope(accessToken: accessToken, gitHubUser: gitHubUser)
    let user = try await fetchOrRegisterUser(env: env)
    try await refreshStripeSubscription(for: user)
    return conn.redirect(to: redirect ?? siteRouter.path(for: .home)) {
      $0.writeSessionCookie { $0.user = .standard(user.id) }
    }
  } catch is GitHubUser.AlreadyRegistered {
    return await conn
      .redirect(
        to: .auth(
          .failureLanding(
            accessToken: accessToken,
            redirect: redirect
          )
        )
      )
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
