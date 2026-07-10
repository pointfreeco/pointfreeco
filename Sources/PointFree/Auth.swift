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
import StyleguideV2
import Tuple
import UrlFormEncoding
import Views

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

func authMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  route: SiteRoute.Auth
) async -> Conn<ResponseEnded, Data> {
  switch route {
  case .codeLanding(let email, let redirect):
    return await loginCodeMiddleware(email: email, redirect: redirect, conn)

  case .connectGitHub(let redirect):
    return await connectGitHub(redirect: redirect, conn: conn)

  case .connectGitHubLanding(let redirect):
    return await connectGitHubLanding(redirect: redirect, conn: conn)

  case .emailAuth(let email, let redirect):
    return await emailAuthResponse(email: email, redirect: redirect, conn: conn)

  case .failureLanding(let redirect):
    return await failureLanding(redirect: redirect, conn: conn)

  case .gitHubAuth(let redirect):
    return await loginResponse(redirect: redirect, conn: conn)

  case .gitHubCallback(let code, let redirect):
    return await gitHubCallbackResponse(code: code, redirect: redirect, conn)

  case .authLanding(let kind, let redirect):
    return await loginSignUpMiddleware(redirect: redirect, kind: kind, conn)

  case .linkGitHubLanding(let redirect):
    return await linkGitHubLanding(redirect: redirect, conn: conn)

  case .logout:
    return await logoutResponse(conn)

  case .updateGitHub(let redirect):
    return await updateGitHub(redirect: redirect, conn: conn)

  case .verifyLoginCode(let email, let code, let redirect):
    return await verifyLoginCodeResponse(email: email, code: code, redirect: redirect, conn: conn)
  }
}

private func emailAuthResponse(
  email: EmailAddress,
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget

  do {
    guard let loginCode = try await database.createEmailLoginCode(email: email)
    else {
      return conn.redirect(to: .auth(.codeLanding(email: email, redirect: redirect))) {
        $0.flash(
          .notice,
          "A code was recently sent to this email. Please wait a minute before requesting another."
        )
      }
    }
    await fireAndForget {
      let html = String(
        decoding: LoginCodeEmail(loginCode: loginCode).render(),
        as: UTF8.self
      )
      await fireAndForget {
        _ = try await send(
          email: Email(
            from: "support@pointfree.co",
            to: [loginCode.email],
            subject: "Your Point-Free login code",
            text: html,
            html: html,
            domain: mgDomain
          )
        )
      }
    }
    return conn.redirect(to: .auth(.codeLanding(email: email, redirect: redirect)))
  } catch {
    return conn.redirect(to: .auth(.authLanding(kind: .login, redirect: redirect))) {
      $0.flash(.error, "We were not able to log you in with that email. Please try again.")
    }
  }
}

private func verifyLoginCodeResponse(
  email: EmailAddress,
  code: EmailLoginCode.Code,
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.siteRouter) var siteRouter

  guard currentUser == nil
  else {
    return conn.redirect(to: .account()) {
      $0.flash(.warning, "You’re already logged in.")
    }
  }

  let code = EmailLoginCode.Code(
    rawValue: code.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
  )

  do {
    _ = try await database.redeemEmailLoginCode(email: email, code: code)
  } catch {
    await withErrorReporting("Burn email login code") {
      try await database.burnEmailLoginCode(email: email)
    }
    return conn.redirect(to: .auth(.authLanding(kind: .login, redirect: redirect))) {
      $0.flash(.error, "That code is not valid or has expired. Please request a new one.")
    }
  }

  do {
    let user: Models.User
    do {
      user = try await database.fetchUser(email: email)
    } catch {
      user = try await registerUser(email: email)
    }
    await notifyError("Email Auth: Refresh stripe failed") {
      try await refreshStripeSubscription(for: user)
    }
    return conn.redirect(to: sanitizeRedirect(redirect) ?? siteRouter.path(for: .home)) {
      $0.writeSessionCookie { $0.user = .standard(user.id) }
    }
  } catch {
    return conn.redirect(to: .auth(.authLanding(kind: .login, redirect: redirect))) {
      $0.flash(.error, "We were not able to log you in. Please try again.")
    }
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
    return conn.redirect(to: .home) {
      $0.flash(.error, "We could not update your GitHub account. Please try again.")
    }
  }

  do {
    let newGitHubUser = try await gitHub.fetchUser(accessToken: accessToken)
    let email = try await gitHub.fetchEmails(accessToken).first(where: \.primary).unwrap().email
    let existingUser = try await database.fetchUser(email: email)
    let existingAccessToken = existingUser.gitHub?.accessToken
    _ = try await database.updateUser(
      id: existingUser.id,
      gitHubUserID: newGitHubUser.id,
      githubAccessToken: accessToken
    )
    await fireAndForget {
      guard let existingAccessToken else { return }
      let email =
      try await gitHub
        .fetchEmails(accessToken: existingAccessToken)
        .first(where: \.primary)
        .unwrap()
        .email
      let html = String(
        decoding: GitHubAccountUpdateEmail(newGitHubUser: newGitHubUser).render(),
        as: UTF8.self
      )
      _ = try await send(
        email: Email(
          from: "support@pointfree.co",
          to: [email],
          subject: "Your GitHub account has been updated",
          text: html,
          html: html,
          domain: mgDomain
        )
      )
    }
    return conn.redirect(to: sanitizeRedirect(redirect) ?? siteRouter.path(for: .home)) {
      $0
        .writeSessionCookie {
          $0.flash = Flash(
            .notice,
            existingAccessToken == nil
              ? "Your GitHub account @\(newGitHubUser.login) has been linked."
              : "Your GitHub account has been updated to @\(newGitHubUser.login)."
          )
          $0.gitHubAccessToken = nil
          $0.user = .standard(existingUser.id)
        }
    }
  } catch {
    return conn.redirect(to: .home) {
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
    return conn.redirect(to: .home) {
      $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
    }
  }

  do {
    let email = try await gitHub.fetchEmails(accessToken).first(where: \.primary).unwrap().email
    let newGitHubUser = try await gitHub.fetchUser(accessToken: accessToken)
    let existingUser = try await database.fetchUser(email: email)
    let existingGitHubUser = try await gitHub.fetchUser(
      id: existingUser.gitHub.unwrap().userId,
      accessToken: accessToken
    )
    return
      conn
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
    return
      conn
      .redirect(to: .home) {
        $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
      }
  }
}

private func connectGitHubLanding(
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.siteRouter) var siteRouter

  guard let currentUser else {
    return conn.redirect(to: .auth(.authLanding(kind: .login, redirect: redirect)))
  }
  guard currentUser.gitHub == nil else {
    return conn.redirect(to: sanitizeRedirect(redirect) ?? siteRouter.path(for: .home)) {
      $0.flash(.notice, "Your GitHub account is already connected.")
    }
  }

  let state: ConnectGitHubView.State
  if let accessToken = conn.request.session.gitHubAccessToken,
    let newGitHubUser = try? await gitHub.fetchUser(accessToken: accessToken)
  {
    if (try? await database.fetchUser(gitHubID: newGitHubUser.id)) != nil {
      state = .conflict(newGitHubUser: newGitHubUser)
    } else {
      state = .confirm(newGitHubUser: newGitHubUser)
    }
  } else {
    state = .ask
  }

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        title: "Connect GitHub"
      )
    ) {
      ConnectGitHubView(state: state, redirect: redirect)
    }
}

private func connectGitHub(
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.siteRouter) var siteRouter

  guard let currentUser else {
    return conn.redirect(to: .auth(.authLanding(kind: .login, redirect: redirect)))
  }
  guard currentUser.gitHub == nil else {
    return conn.redirect(to: sanitizeRedirect(redirect) ?? siteRouter.path(for: .home)) {
      $0.flash(.notice, "Your GitHub account is already connected.")
    }
  }
  guard let accessToken = conn.request.session.gitHubAccessToken else {
    return conn.redirect(to: .auth(.connectGitHubLanding(redirect: redirect)))
  }

  do {
    let newGitHubUser = try await gitHub.fetchUser(accessToken: accessToken)
    guard (try? await database.fetchUser(gitHubID: newGitHubUser.id)) == nil else {
      return conn.redirect(to: .auth(.connectGitHubLanding(redirect: redirect)))
    }
    try await database.updateUser(
      id: currentUser.id,
      gitHubUserID: newGitHubUser.id,
      githubAccessToken: accessToken
    )
    return conn.redirect(to: sanitizeRedirect(redirect) ?? siteRouter.path(for: .home)) {
      $0.writeSessionCookie {
        $0.flash = Flash(
          .notice,
          "Your GitHub account @\(newGitHubUser.login) has been connected."
        )
        $0.gitHubAccessToken = nil
      }
    }
  } catch {
    return conn.redirect(to: .auth(.connectGitHubLanding(redirect: redirect))) {
      $0.flash(.error, "We were not able to connect your GitHub account. Please try again.")
    }
  }
}

private func linkGitHubLanding(
  redirect: String?,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.gitHub) var gitHub

  guard let accessToken = conn.request.session.gitHubAccessToken else {
    return conn.redirect(to: .home) {
      $0.flash(.error, "We were not able to log you in with GitHub. Please try again.")
    }
  }

  do {
    let email = try await gitHub.fetchEmails(accessToken).first(where: \.primary).unwrap().email
    let newGitHubUser = try await gitHub.fetchUser(accessToken: accessToken)
    let existingUser = try await database.fetchUser(email: email)
    guard existingUser.gitHub == nil
    else {
      return conn.redirect(to: .auth(.failureLanding(redirect: redirect)))
    }
    return
      conn
      .writeStatus(.ok)
      .respondV2(
        layoutData: SimplePageLayoutData(
          title: "Link your GitHub account"
        )
      ) {
        LinkGitHubView(
          email: email,
          newGitHubUser: newGitHubUser,
          redirect: redirect
        )
      }
  } catch {
    return
      conn
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

  guard currentUser?.gitHub == nil
  else {
    return conn.redirect(to: .account()) {
      $0.flash(.warning, "You’re already logged in.")
    }
  }
  guard let code
  else {
    return conn.redirect(to: .auth(.authLanding(kind: .login))) {
      $0.flash(.warning, "GitHub code wasn't found :(")
    }
  }
  do {
    let accessToken = try await gitHub.fetchAuthToken(code: code).accessToken
    if currentUser != nil {
      return conn.redirect(to: .auth(.connectGitHubLanding(redirect: redirect))) {
        $0.writeSessionCookie {
          $0.gitHubAccessToken = accessToken
        }
      }
    }
    return await gitHubAuthTokenMiddleware(
      code: code,
      accessToken: accessToken,
      redirect: redirect,
      conn
    )
  } catch let error as OAuthError where error.error == .badVerificationCode {
    return conn.redirect(to: .auth(.gitHubAuth(redirect: redirect)))
  } catch {
    return conn.redirect(to: .home) {
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

  guard currentUser?.gitHub == nil
  else {
    return conn.redirect(to: .account()) {
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

  return
    await conn
    .redirect(to: url)
}

private func logoutResponse(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  conn.redirect(to: .home) { $0.writeSessionCookie { $0.user = nil } }
}

extension Conn where Step == StatusLineOpen {
  public func loginAndRedirect() -> Conn<ResponseEnded, Data> {
    redirect(to: .auth(.gitHubAuth(redirect: request.url?.absoluteString)))
  }
}

public func loginAndRedirect<A>(_ conn: Conn<StatusLineOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  IO { conn.loginAndRedirect() }
}

private func fetchOrRegisterUser(
  accessToken: GitHubAccessToken,
  gitHubUser: GitHubUser
) async throws -> Models.User {
  @Dependency(\.database) var database

  do {
    let user = try await database.fetchUser(gitHubID: gitHubUser.id)
    try await database.updateUser(id: user.id, githubAccessToken: accessToken)
    return user
  } catch {
    return try await registerUser(accessToken: accessToken, gitHubUser: gitHubUser)
  }
}

extension GitHubUser {
  public struct AlreadyRegistered: Error {
    let email: EmailAddress
  }

  public struct AlreadyRegisteredViaEmail: Error {
    let email: EmailAddress
  }
}

private func registerUser(email: EmailAddress) async throws -> Models.User {
  @Dependency(\.database) var database

  let user = try await database.registerUser(email: email)
  await sendRegistrationEmail(to: email)
  return user
}

private func sendRegistrationEmail(to email: EmailAddress) async {
  @Dependency(\.fireAndForget) var fireAndForget

  await fireAndForget {
    try await sendEmail(
      to: [email],
      subject: "Point-Free Registration",
      content: inj2(registrationEmailView(unit))
    )
  }
}

private func registerUser(
  accessToken: GitHubAccessToken,
  gitHubUser: GitHubUser
) async throws -> Models.User {
  @Dependency(\.database) var database
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
    await sendRegistrationEmail(to: email)
    return user
  } catch let error as PSQLError
    where
    error.serverInfo?[.constraintName] == "users_email_key"
    && error.serverInfo?[.routine] == "_bt_check_unique"
  {
    let existingUser = try await database.fetchUser(email: email)
    if existingUser.gitHub == nil {
      throw GitHubUser.AlreadyRegisteredViaEmail(email: email)
    } else {
      throw GitHubUser.AlreadyRegistered(email: email)
    }
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
    await notifyError("GitHub Auth: Refresh stripe failed") {
      try await refreshStripeSubscription(for: user)
    }
    return conn.redirect(to: sanitizeRedirect(redirect) ?? siteRouter.path(for: .home)) {
      $0.writeSessionCookie { $0.user = .standard(user.id) }
    }
  } catch is GitHubUser.AlreadyRegistered {
    return conn.redirect(to: .auth(.failureLanding(redirect: redirect))) {
      $0.writeSessionCookie {
        $0.gitHubAccessToken = accessToken
      }
    }
  } catch is GitHubUser.AlreadyRegisteredViaEmail {
    return conn.redirect(to: .auth(.linkGitHubLanding(redirect: redirect))) {
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

func refreshStripeSubscription(for user: Models.User) async throws {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  guard let subscriptionId = user.subscriptionId else { return }

  let subscription = try await database.fetchSubscription(id: subscriptionId)
  let stripeSubscription =
    try await stripe
    .fetchSubscription(subscription.stripeSubscriptionId)
  _ = try await database.updateStripeSubscription(stripeSubscription)
}

struct LoginCodeEmail: EmailDocument {
  let loginCode: EmailLoginCode

  var body: some HTML {
    SimpleEmailLayout(
      preheader: "Your Point-Free login code is \(loginCode.code)."
    ) {
      tr {
        td {
          EmailMarkdown {
            """
            ## Your login code

            Enter this code on the Point-Free login page to finish logging in. It expires in \
            one hour.

            # \(loginCode.code)

            If you did not request this code you can safely ignore this email.
            """
          }
        }
      }
    }
  }
}

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

private func sanitizeRedirect(_ redirect: String?) -> String? {
  @Dependency(\.envVars.baseUrl) var baseUrl
  guard
    let redirect,
    let url = URL(string: redirect)
  else { return nil }
  guard
    let host = url.host,
    host == baseUrl.host
  else {
    guard
      redirect.hasPrefix("/"),
      !redirect.hasPrefix("//")
    else { return nil }
    return redirect
  }

  return redirect
}
