import Css
import Dependencies
import Either
import EmailAddress
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Tagged
import Tuple
import UrlFormEncoding
import Views

let enterpriseLandingResponse =
  requireEnterpriseAccount
  <| writeStatus(.ok)
  >=> respond(
    view: enterpriseView,
    layoutData: { enterpriseAccount in
      SimplePageLayoutData(
        data: enterpriseAccount,
        style: .base(.minimal(.dark)),
        title: "Point-Free 🤝 \(enterpriseAccount.companyName)"
      )
    }
  )

private let requireEnterpriseAccount:
  MT<
    EnterpriseAccount.Domain,
    EnterpriseAccount
  > = { middleware in
    return { conn in
      return IO {
        guard let account = await fetchEnterpriseAccount(conn.data).performAsync()
        else {
          return await
            (conn
            |> redirect(
              to: .home,
              headersMiddleware: flash(.warning, "That enterprise account does not exist.")
            )).performAsync()
        }

        return await middleware(conn.map(const(account))).performAsync()
      }
    }
  }

let enterpriseRequestMiddleware =
  requireEnterpriseAccountWithFormData
  <<< validateMembership
  <<< sendEnterpriseInvitation
  <| { conn in
    conn
      |> redirect(
        to: .enterprise(get1(conn.data).domain),
        headersMiddleware: flash(
          .notice, "We've sent an invite to \(get2(conn.data).email.rawValue)!")
      )
  }

private let requireEnterpriseAccountWithFormData:
  MT<
    Tuple2<EnterpriseAccount.Domain, EnterpriseRequestFormData>,
    Tuple2<EnterpriseAccount, EnterpriseRequestFormData>
  > = filterMap(
    over1(fetchEnterpriseAccount) >>> sequence1 >>> map(require1), or: redirect(to: .home)
  )

let enterpriseAcceptInviteMiddleware =
  redirectCurrentSubscribersAndRequireEnterpriseAccount
  <<< validateInvitationAndLink
  <| successfullyAcceptedInviteMiddleware

private let redirectCurrentSubscribersAndRequireEnterpriseAccount:
  MT<
    Tuple4<User?, EnterpriseAccount.Domain, Encrypted<String>, Encrypted<String>>,
    Tuple4<User, EnterpriseAccount, Encrypted<String>, Encrypted<String>>
  > =
    filterMap(require1 >>> pure, or: loginAndRedirect) <<< redirectCurrentSubscribers
    <<< requireEnterpriseAccount

private let validateInvitationAndLink:
  MT<
    Tuple4<User, EnterpriseAccount, Encrypted<String>, Encrypted<String>>,
    Tuple4<User, EnterpriseAccount, EmailAddress, User.ID>
  > =
    filterMap(
      validateInvitation >>> pure,
      or: invalidInvitationLinkMiddleware(
        reason: "Something is wrong with your invitation link. Please try again."
      )
    )
    <<< filterMap(
      createEnterpriseEmail,
      or: invalidInvitationLinkMiddleware(reason: "This invitation has already been used.")
    )
    <<< filterMap(
      linkToEnterpriseSubscription,
      or: invalidInvitationLinkMiddleware(
        reason: "Something is wrong with your invitation link. Please try again."
      )
    )

private func requireEnterpriseAccount<A, Z>(
  _ middleware: @escaping M<T3<A, EnterpriseAccount, Z>>
) -> M<T3<A, EnterpriseAccount.Domain, Z>> {

  return middleware
    |> filterMap(
      over2(fetchEnterpriseAccount) >>> sequence2 >>> map(require2),
      or: redirect(
        to: .home,
        headersMiddleware: flash(.warning, "That enterprise account does not exist.")
      )
    )
}

private func createEnterpriseEmail(
  _ data: Tuple4<User, EnterpriseAccount, EmailAddress, User.ID>
) -> IO<Tuple4<User, EnterpriseAccount, EmailAddress, User.ID>?> {
  @Dependency(\.database) var database

  return IO {
    do {
      _ = try await database.createEnterpriseEmail(emailAddress: get3(data), userID: get4(data))
      return data
    } catch {
      return nil
    }
  }
}

private func linkToEnterpriseSubscription<Z>(
  _ data: T3<User, EnterpriseAccount, Z>
) -> IO<T3<User, EnterpriseAccount, Z>?> {
  @Dependency(\.database) var database

  return EitherIO {
    try await database.addUser(id: get1(data).id, toSubscriptionID: get2(data).subscriptionId)
  }
  .map(const(data))
  .run
  .map(\.right)
}

private func successfullyAcceptedInviteMiddleware<A, Z>(
  _ conn: Conn<StatusLineOpen, T3<A, EnterpriseAccount, Z>>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.siteRouter) var siteRouter

  let account = get2(conn.data)

  return conn
    |> redirect(
      to: siteRouter.path(for: .account()),
      headersMiddleware: flash(.notice, "You have joined \(account.companyName)'s subscription!")
    )
}

private func invalidInvitationLinkMiddleware<A, Z>(reason: String)
  -> (Conn<StatusLineOpen, T3<A, EnterpriseAccount, Z>>)
  -> IO<Conn<ResponseEnded, Data>>
{
  @Dependency(\.siteRouter) var siteRouter

  return { conn in
    conn
      |> redirect(
        to: siteRouter.path(for: .enterprise(get2(conn.data).domain)),
        headersMiddleware: flash(.error, reason)
      )
  }
}

private func validateMembership<Z>(
  _ middleware: @escaping M<T2<EnterpriseAccount, Z>>
) -> M<T2<EnterpriseAccount, Z>> {
  return { conn in
    @Dependency(\.currentUser) var currentUser
    let account = get1(conn.data)

    if currentUser?.subscriptionId == account.subscriptionId {
      return conn
        |> redirect(
          to: .account(),
          headersMiddleware: flash(
            .notice,
            "🙌 You're already enrolled in \(account.companyName)'s subscription!"
          )
        )
    } else {
      return middleware(conn)
    }
  }
}

private func validateInvitation(
  _ data: Tuple4<User, EnterpriseAccount, Encrypted<String>, Encrypted<String>>
) -> Tuple4<User, EnterpriseAccount, EmailAddress, User.ID>? {
  @Dependency(\.envVars.appSecret) var appSecret

  let (user, account, encryptedEmail, encryptedUserId) = lower(data)

  // Make sure email decrypts correctly
  guard
    let email = encryptedEmail.decrypt(with: appSecret)
      .map(EmailAddress.init(rawValue:))
  else { return nil }

  // Make sure email address is on the same domain as the enterprise account
  guard account.domains.contains(where: email.hasDomain)
  else { return nil }

  // Make sure user id decrypts correctly.
  guard
    let userId = encryptedUserId.decrypt(with: appSecret)
      .flatMap(UUID.init(uuidString:))
      .map(User.ID.init(rawValue:))
  else { return nil }

  // Validates that the userId encrypted into the invite link is the same as the email accepting the
  // invitation.
  guard userId == user.id
  else { return nil }

  return .some(
    data
      |> over3(const(email))
      |> over4(const(userId))
  )
}

private func sendEnterpriseInvitation<Z>(
  _ middleware: @escaping M<T3<EnterpriseAccount, EnterpriseRequestFormData, Z>>
) -> M<T3<EnterpriseAccount, EnterpriseRequestFormData, Z>> {
  @Dependency(\.envVars.appSecret) var appSecret
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  return { conn in
    guard let currentUser = currentUser
    else { return loginAndRedirect(conn) }

    let (account, request) = (get1(conn.data), get2(conn.data))

    if !account.domains.contains(where: request.email.hasDomain) {
      let domains = account.domains.map { "\"\($0)\"" }.joined(separator: ", ")
      return conn
        |> redirect(
          to: siteRouter.path(for: .enterprise(account.domain)),
          headersMiddleware: flash(
            .error,
            "The email you entered must be on one of the following domains: \(domains)"
          )
        )
    } else if let encryptedEmail = Encrypted(
      request.email.rawValue, with: appSecret),
      let encryptedUserId = Encrypted(currentUser.id.rawValue.uuidString, with: appSecret)
    {
      Task {
        _ = try await sendEmail(
          to: [request.email],
          subject: "You’re invited to join the \(account.companyName) team on Point-Free",
          content: inj2(enterpriseInviteEmailView((account, encryptedEmail, encryptedUserId)))
        )
      }
      return conn
        |> middleware
    } else {
      return conn
        |> redirect(
          to: siteRouter.path(for: .enterprise(account.domain)),
          headersMiddleware: flash(
            .warning,
            "Something went wrong. Please try again or contact <support@pointfree.co>."
          )
        )
    }
  }
}

func fetchEnterpriseAccount(_ domain: EnterpriseAccount.Domain) -> IO<EnterpriseAccount?> {
  @Dependency(\.database) var database

  return IO { try? await database.fetchEnterpriseAccount(forDomain: domain) }
}

let enterpriseInviteEmailView =
  simpleEmailLayout(enterpriseInviteEmailBodyView)
  <<< { account, encryptedEmail, encryptedUserId in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You’re invited to join the \(account.companyName) team on Point-Free",
      preheader: "You’re invited to join the \(account.companyName) team on Point-Free.",
      template: .default(),
      data: (account, encryptedEmail, encryptedUserId)
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

private func redirectCurrentSubscribers<Z>(
  _ middleware: @escaping M<T2<User, Z>>
) -> M<T2<User, Z>> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  return { conn in
    let user = get1(conn.data)
    guard let subscriptionId = user.subscriptionId
    else { return middleware(conn) }

    return EitherIO {
      let subscription = try await database.fetchSubscription(id: subscriptionId)
      let stripeSubscription =
        try await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      return stripeSubscription.isRenewing
    }
    .run
    .map { $0.right ?? false }
    .flatMap {
      $0
        ? conn
          |> redirect(
            to: .account(),
            headersMiddleware: flash(
              .warning,
              """
              You already have an active subscription. If you want to accept this team invite you need to
              cancel your current subscription.
              """
            )
          )
        : middleware(conn)
    }
  }
}
