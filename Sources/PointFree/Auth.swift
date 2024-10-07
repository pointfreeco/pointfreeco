import CustomDump
import Dependencies
import Either
import EmailAddress
import Foundation
import GitHub
import HttpPipeline
import Mailgun
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
  case .failureLanding(redirect: let redirect):
    return await failureLanding(
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

  case .updateGitHub(let redirect):
    return await updateGitHub(
      redirect: redirect,
      conn: conn.map(const(()))
    )
  }
}

private func updateGitHub(
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.date) var date
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.siteRouter) var siteRouter

  guard let accessToken = conn.request.session.gitHubAccessToken else {
    return conn
      .redirect(to: .home) {
        $0.flash(.error, "We could not update your GitHub account. Please try again.")
      }
  }

  do {
    let newGitHubUser = try await gitHub.fetchUser(accessToken: accessToken)
    let email = try await gitHub.fetchEmails(accessToken).first(where: \.primary).unwrap().email
    let existingUser = try await database.fetchUser(email: email)
    let existingAccessToken = existingUser.gitHubAccessToken
    _ = try await database.updateUser(
      id: existingUser.id,
      gitHubUserID: newGitHubUser.id,
      githubAccessToken: accessToken
    )
    await fireAndForget {
      let email = try await gitHub
        .fetchEmails(accessToken: existingAccessToken)
        .first(where: \.primary)
        .unwrap()
        .email
      let html = String(
        decoding: GitHubAccountUpdateEmail(newGitHubUser: newGitHubUser).render(),
        as: UTF8.self
      ) 
      do {
        _ = try await send(
          email: Email(
            from: "support@pointfree.co",
            to: [email, "brandon@pointfree.co"],
            subject: "Your GitHub account has been updated",
            text: html,
            html: html,
            domain: mgDomain
          )
        )
      } catch {
        reportIssue(error, "Unable to send email: \"Your GitHub account has been updated\"")
      }
    }
    return conn
      .redirect(to: redirect ?? siteRouter.path(for: .home)) {
        $0
          .writeSessionCookie {
            $0.flash = Flash(
              .notice,
              "Your GitHub account has been updated to @\(newGitHubUser.login)."
            )
            $0.gitHubAccessToken = nil
            $0.user = .standard(existingUser.id)
          }
    }
  } catch {
    return conn
      .redirect(to: .home) {
        $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
      }
  }
}

private func failureLanding(
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.gitHub) var gitHub

  guard let accessToken = conn.request.session.gitHubAccessToken else {
    return conn
      .redirect(to: .home) {
        $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
      }
  }

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
    let accessToken = try await gitHub.fetchAuthToken(code: code).accessToken
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

private func fetchOrRegisterUser(
  accessToken: GitHubAccessToken,
  gitHubUser: GitHubUser
) async throws -> Models.User {
  @Dependency(\.database) var database

  do {
    return try await database.fetchUser(gitHubID: gitHubUser.id)
  } catch {
    return try await registerUser(
      accessToken: accessToken,
      gitHubUser: gitHubUser
    )
  }
}

extension GitHubUser {
  public struct AlreadyRegistered: Error {
    let email: EmailAddress
  }
}

private func registerUser(
  accessToken: GitHubAccessToken,
  gitHubUser: GitHubUser
) async throws -> Models.User {
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.date.now) var now

  let email = try await gitHub.fetchEmails(accessToken).first(where: \.primary).unwrap().email
  do {
    let user = try await database.registerUser(
      accessToken: accessToken,
      gitHubUser: gitHubUser,
      email: email,
      now: { now }
    )
    await fireAndForget {
      try await sendEmail(
        to: [email],
        subject: "Point-Free Registration",
        content: inj2(registrationEmailView(gitHubUser))
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
  accessToken: GitHubAccessToken,
  redirect: String?,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.siteRouter) var siteRouter

  do {
    let gitHubUser = try await gitHub.fetchUser(accessToken)
    let user = try await fetchOrRegisterUser(accessToken: accessToken, gitHubUser: gitHubUser)
    try await refreshStripeSubscription(for: user)
    return conn.redirect(to: redirect ?? siteRouter.path(for: .home)) {
      $0.writeSessionCookie { $0.user = .standard(user.id) }
    }
  } catch is GitHubUser.AlreadyRegistered {
    return conn
      .redirect(to: .auth(.failureLanding(redirect: redirect))) {
        $0.writeSessionCookie {
          $0.gitHubAccessToken = accessToken
        }
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

import StyleguideV2

struct GitHubAccountUpdateEmail: EmailDocument {
  let newGitHubUser: GitHubUser

  var body: some HTML {
    SimpleEmailLayout(
      preheader: """
        The GitHub user for your Point-Free account has been updated to @\(newGitHubUser.login)
        """
    ) {
      tr {
        td {
          EmailMarkdown {
          """
          ## Your GitHub account has been updated
          
          Hi there, the GitHub user for your Point-Free account has been updated to
          **[@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login))**. If you did not
          request this change, or you do not recognize the GitHub account
          [@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login)), please
          [contact us](mailto:support@pointfree.co) immediately.
          """
          }
        }
      }
    }
  }
}

struct SimpleEmailLayout<Content: HTML>: HTML {
  let content: Content
  let preheader: String
  @Dependency(\.envVars.appSecret) var appSecret
  @Dependency(\.siteRouter) var siteRouter

  init(
    preheader: String = "",
    @HTMLBuilder content: () -> Content
  ) {
    self.content = content()
    self.preheader = preheader
  }

  var body: some HTML {
    span {
      HTMLText(preheader)
    }
    .color(.init(rawValue: "transparent"))
    .inlineStyle("display", "none")
    .inlineStyle("opacity", "0")
    .inlineStyle("width", "0")
    .inlineStyle("height", "0")
    .inlineStyle("maxWidth", "0")
    .inlineStyle("maxHeight", "0")
    .inlineStyle("overflow", "hidden")

    table {
      content

      tr {
        td {
          div {
            EmailMarkdown {
              """
              Contact us via email at [support@pointfree.co](mailto:support@pointfree.co), 
              [Twitter](http://x.com/pointfreeco), or on 
              [Mastodon](https://hachyderm.io/@pointfreeco). Our postal address: 139 Skillman #5C, 
              Brooklyn, NY 11211.
              """
            }
            .color(.gray300)
            .fontStyle(.body(.small))
            .linkColor(.offBlack)
          }
          .backgroundColor(.gray900)
          .inlineStyle("padding", "2rem 2rem 1.5rem 2rem")
          .inlineStyle("margin", "2rem 0")
        }
      }
    }
    .attribute("role", "presentation")
    .attribute("height", "100%")
    .attribute("width", "100%")
    .attribute("border-collapse", "collapse")
    .attribute("border-spacing", "0 0.5rem")
    .attribute("align", "center")
    .inlineStyle("display", "block")
    .inlineStyle("width", "100%")
    .inlineStyle("max-width", "600px")
    .inlineStyle("margin", "0 auto")
    .inlineStyle("clear", "both")
    .linkStyle(LinkStyle(color: .purple, underline: true))
  }
}
