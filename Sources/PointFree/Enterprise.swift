import Css
import Dependencies
import Either
import EmailAddress
import Foundation
import FunctionalCss
import Html
import HttpPipeline
import Mailgun
import Models
import PointFreeRouter
import Styleguide
import Views

func enterpriseLandingResponse(
  _ conn: Conn<StatusLineOpen, Void>,
  domain: EnterpriseAccount.Domain
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database

  guard let account = try? await database.fetchEnterpriseAccount(forDomain: domain)
  else {
    return conn.redirect(to: .home) {
      $0.flash(.warning, "That enterprise account does not exist.")
    }
  }

  return conn
    .writeStatus(.ok)
    .respond(
      view: enterpriseView,
      layoutData: {
        SimplePageLayoutData(
          data: account,
          style: .base(.minimal(.dark)),
          title: "Point-Free 🤝 \(account.companyName)"
        )
      }
    )
}

func enterpriseRequestMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  domain: EnterpriseAccount.Domain,
  request: EnterpriseRequestFormData
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.envVars.appSecret) var appSecret
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  guard let account = try? await database.fetchEnterpriseAccount(forDomain: domain)
  else { return conn.redirect(to: .home) }

  guard let currentUser
  else { return conn.loginAndRedirect() }

  if currentUser.subscriptionId == account.subscriptionId {
    return conn.redirect(to: .account()) {
      $0.flash(
        .notice,
        "🙌 You're already enrolled in \(account.companyName)'s subscription!"
      )
    }
  }

  if !account.domains.contains(where: request.email.hasDomain) {
    let domains = account.domains.map { "\"\($0)\"" }.joined(separator: ", ")
    return conn.redirect(to: siteRouter.path(for: .enterprise(account.domain))) {
      $0.flash(
        .error,
        "The email you entered must be on one of the following domains: \(domains)"
      )
    }
  }

  guard
    let encryptedEmail = Encrypted(request.email.rawValue, with: appSecret),
    let encryptedUserId = Encrypted(currentUser.id.rawValue.uuidString, with: appSecret)
  else {
    return conn.redirect(to: siteRouter.path(for: .enterprise(account.domain))) {
      $0.flash(
        .warning,
        "Something went wrong. Please try again or contact <support@pointfree.co>."
      )
    }
  }

  Task {
    _ = try await sendEmail(
      to: [request.email],
      subject: "You’re invited to join the \(account.companyName) team on Point-Free",
      content: inj2(enterpriseInviteEmailView(account, encryptedEmail, encryptedUserId))
    )
  }

  return conn.redirect(to: .enterprise(account.domain)) {
    $0.flash(.notice, "We've sent an invite to \(request.email.rawValue)!")
  }
}

func enterpriseAcceptInviteMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  currentUser: User?,
  domain: EnterpriseAccount.Domain,
  encryptedEmail: Encrypted<String>,
  encryptedUserId: Encrypted<String>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe
  @Dependency(\.siteRouter) var siteRouter

  guard let user = currentUser
  else { return conn.loginAndRedirect() }

  guard let account = try? await database.fetchEnterpriseAccount(forDomain: domain)
  else {
    return conn.redirect(to: .home) {
      $0.flash(.warning, "That enterprise account does not exist.")
    }
  }

  if let subscriptionId = user.subscriptionId,
    let subscription = try? await database.fetchSubscription(id: subscriptionId),
    let stripeSubscription = try? await stripe.fetchSubscription(subscription.stripeSubscriptionId),
    stripeSubscription.isRenewing
  {
    return conn.redirect(to: .account()) {
      $0.flash(
        .warning,
        """
        You already have an active subscription. If you want to accept this team invite you need to
        cancel your current subscription.
        """
      )
    }
  }

  guard
    let (email, userId) = validateInvitation(
      user: user,
      account: account,
      encryptedEmail: encryptedEmail,
      encryptedUserId: encryptedUserId
    )
  else {
    return invalidInvitationLinkResponse(
      conn,
      domain: account.domain,
      reason: "Something is wrong with your invitation link. Please try again."
    )
  }

  do {
    _ = try await database.createEnterpriseEmail(emailAddress: email, userID: userId)
  } catch {
    return invalidInvitationLinkResponse(
      conn,
      domain: account.domain,
      reason: "This invitation has already been used."
    )
  }

  do {
    try await database.addUser(id: user.id, toSubscriptionID: account.subscriptionId)
  } catch {
    return invalidInvitationLinkResponse(
      conn,
      domain: account.domain,
      reason: "Something is wrong with your invitation link. Please try again."
    )
  }

  return conn.redirect(to: siteRouter.path(for: .account())) {
    $0.flash(.notice, "You have joined \(account.companyName)'s subscription!")
  }
}

private func invalidInvitationLinkResponse(
  _ conn: Conn<StatusLineOpen, Void>,
  domain: EnterpriseAccount.Domain,
  reason: String
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.siteRouter) var siteRouter

  return conn.redirect(to: siteRouter.path(for: .enterprise(domain))) {
    $0.flash(.error, reason)
  }
}

private func validateInvitation(
  user: User,
  account: EnterpriseAccount,
  encryptedEmail: Encrypted<String>,
  encryptedUserId: Encrypted<String>
) -> (EmailAddress, User.ID)? {
  @Dependency(\.envVars.appSecret) var appSecret

  guard
    let email = encryptedEmail.decrypt(with: appSecret)
      .map(EmailAddress.init(rawValue:))
  else { return nil }

  guard account.domains.contains(where: email.hasDomain)
  else { return nil }

  guard
    let userId = encryptedUserId.decrypt(with: appSecret)
      .flatMap(UUID.init(uuidString:))
      .map(User.ID.init(rawValue:))
  else { return nil }

  guard userId == user.id
  else { return nil }

  return (email, userId)
}

func enterpriseInviteEmailView(
  _ account: EnterpriseAccount,
  _ encryptedEmail: Encrypted<String>,
  _ encryptedUserId: Encrypted<String>
) -> Node {
  simpleEmailLayout(enterpriseInviteEmailBodyView)(
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You’re invited to join the \(account.companyName) team on Point-Free",
      preheader: "You’re invited to join the \(account.companyName) team on Point-Free.",
      template: .default(),
      data: (account, encryptedEmail, encryptedUserId)
    )
  )
}

private func enterpriseInviteEmailBodyView(
  account: EnterpriseAccount,
  encryptedEmail: Encrypted<String>,
  encryptedUserId: Encrypted<String>
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])], "You’re invited!"),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "You’re invited to join the ", .text(account.companyName),
            " team on Point-Free, a video series exploring advanced programming topics in Swift. ",
            "To accept, simply click the link below!"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(
                  siteRouter.url(
                    for: .enterprise(
                      account.domain, .acceptInvite(email: encryptedEmail, userId: encryptedUserId)
                    )
                  )
                ),
                .class([Class.pf.components.button(color: .purple)]),
              ],
              "Click here to accept!"
            )
          )
        )
      )
    )
  )
}

extension EmailAddress {
  fileprivate func hasDomain(_ domain: EnterpriseAccount.Domain) -> Bool {
    self.rawValue.lowercased().hasSuffix("@\(domain.rawValue.lowercased())")
  }
}
