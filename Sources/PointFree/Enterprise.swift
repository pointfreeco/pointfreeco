import Css
import Either
import FunctionalCss
import Foundation
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
import View
import Views

let enterpriseLandingResponse: AppMiddleware<Tuple3<User?, SubscriberState, EnterpriseAccount.Domain>>
  = filterMap(
    over3(fetchEnterpriseAccount) >>> sequence3 >>> map(require3),
    or: redirect(
      to: .home,
      headersMiddleware: flash(.warning, "That enterprise account does not exist.")
    )
    )
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: View(enterpriseView),
      layoutData: { user, subscriberState, enterpriseAccount in
        SimplePageLayoutData(
          currentSubscriberState: subscriberState,
          currentUser: user,
          data: (user, enterpriseAccount),
          style: .base(.minimal(.dark)),
          title: "Point-Free 🤝 \(enterpriseAccount.companyName)"
        )
    }
)

let enterpriseRequestMiddleware: AppMiddleware<Tuple3<User?, EnterpriseAccount.Domain, EnterpriseRequestFormData>>
  = filterMap(over2(fetchEnterpriseAccount) >>> sequence2 >>> map(require2), or: redirect(to: .home))
    <<< validateMembership
    <<< filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< sendEnterpriseInvitation
    <| { conn in
      conn |> redirect(
        to: .enterprise(.landing(get2(conn.data).domain)),
        headersMiddleware: flash(.notice, "We've sent an invite to \(get3(conn.data).email.rawValue)!")
      )
}

let enterpriseAcceptInviteMiddleware: AppMiddleware<Tuple4<User?, EnterpriseAccount.Domain, Encrypted<String>, Encrypted<String>>>
  = filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< redirectCurrentSubscribers
    <<< requireEnterpriseAccount
    <<< filterMap(
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
    <| successfullyAcceptedInviteMiddleware

private func requireEnterpriseAccount<A, Z>(
  _ middleware: @escaping AppMiddleware<T3<A, EnterpriseAccount, Z>>
  ) -> AppMiddleware<T3<A, EnterpriseAccount.Domain, Z>> {

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
  _ data: Tuple4<User, EnterpriseAccount, EmailAddress, User.Id>
  ) -> IO<Tuple4<User, EnterpriseAccount, EmailAddress, User.Id>?> {

  return Current.database.createEnterpriseEmail(get3(data), get4(data))
    .map(const(data))
    .run
    .map(^\.right)
}

private func linkToEnterpriseSubscription<Z>(
  _ data: T3<User, EnterpriseAccount, Z>
  ) -> IO<T3<User, EnterpriseAccount, Z>?> {

  return Current.database.addUserIdToSubscriptionId(get1(data).id, get2(data).subscriptionId)
    .map(const(data))
    .run
    .map(^\.right)
}

private func successfullyAcceptedInviteMiddleware<A, Z>(
  _ conn: Conn<StatusLineOpen, T3<A, EnterpriseAccount, Z>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let account = get2(conn.data)

  return conn
    |> redirect(
      to: pointFreeRouter.path(to: .account(.index)),
      headersMiddleware: flash(.notice, "You have joined \(account.companyName)'s subscription!")
  )
}

private func invalidInvitationLinkMiddleware<A, Z>(reason: String)
  -> (Conn<StatusLineOpen, T3<A, EnterpriseAccount, Z>>)
  -> IO<Conn<ResponseEnded, Data>> {
    return { conn in
      conn
        |> redirect(
          to: pointFreeRouter.path(to: .enterprise(.landing(get2(conn.data).domain))),
          headersMiddleware: flash(.error, reason)
      )
    }
}

private func validateMembership<Z>(
  _ middleware: @escaping AppMiddleware<T3<User?, EnterpriseAccount, Z>>
  ) -> AppMiddleware<T3<User?, EnterpriseAccount, Z>> {

  return { conn in
    let (user, account) = (get1(conn.data), get2(conn.data))

    if user?.subscriptionId == account.subscriptionId {
      return conn |> redirect(
        to: .account(.index),
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
  ) -> Tuple4<User, EnterpriseAccount, EmailAddress, User.Id>? {

  let (user, account, encryptedEmail, encryptedUserId) = lower(data)

  // Make sure email decrypts correctly
  guard let email = encryptedEmail.decrypt(with: Current.envVars.appSecret)
    .map(EmailAddress.init(rawValue:))
    else { return nil }

  // Make sure email address is on the same domain as the enterprise account
  guard email.hasDomain(account.domain)
    else { return nil }

  // Make sure user id decrypts correctly.
  guard let userId = encryptedUserId.decrypt(with: Current.envVars.appSecret)
    .flatMap(UUID.init(uuidString:))
    .map(User.Id.init(rawValue:))
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
  _ middleware: @escaping AppMiddleware<T4<User, EnterpriseAccount, EnterpriseRequestFormData, Z>>
  ) -> AppMiddleware<T4<User, EnterpriseAccount, EnterpriseRequestFormData, Z>> {

  return { conn in
    let (user, account, request) = (get1(conn.data), get2(conn.data), get3(conn.data))

    if !request.email.hasDomain(account.domain) {
      return conn
        |> redirect(
          to: pointFreeRouter.path(to: .enterprise(.landing(account.domain))),
          headersMiddleware: flash(
            .error,
            "The email you entered does not come from the @\(account.domain) domain."
          )
      )
    } else if
      let encryptedEmail = Encrypted(request.email.rawValue, with: Current.envVars.appSecret),
      let encryptedUserId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret) {

      sendEmail(
        to: [request.email],
        subject: "You’re invited to join the \(account.companyName) team on Point-Free",
        content: inj2(enterpriseInviteEmailView.view((account, encryptedEmail, encryptedUserId)))
        )
        .run
        .parallel
        .run({ _ in })
      return conn
        |> middleware
    } else {
      return conn
        |> redirect(
          to: pointFreeRouter.path(to: .enterprise(.landing(account.domain))),
          headersMiddleware: flash(
            .warning,
            "Something went wrong. Please try again or contact <support@pointfree.co>."
          )
      )
    }
  }
}

func fetchEnterpriseAccount(_ domain: EnterpriseAccount.Domain) -> IO<EnterpriseAccount?> {
  return Current.database.fetchEnterpriseAccountForDomain(domain)
    .mapExcept(requireSome)
    .run
    .map(^\.right)
}

let enterpriseInviteEmailView = simpleEmailLayout(enterpriseInviteEmailBodyView)
  .contramap { account, encryptedEmail, encryptedUserId in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You’re invited to join the \(account.companyName) team on Point-Free",
      preheader: "You’re invited to join the \(account.companyName) team on Point-Free.",
      template: .default,
      data: (account, encryptedEmail, encryptedUserId)
    )
}

private let enterpriseInviteEmailBodyView = View<(EnterpriseAccount, Encrypted<String>, Encrypted<String>)> { account, encryptedEmail, encryptedUserId in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["You’re invited!"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "You’re invited to join the ", .text(account.companyName), " team on Point-Free, a video series ",
            "about functional programming and the Swift programming language. To accept, simply click the ",
            "link below!"
            ]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .enterprise(.acceptInvite(account.domain, email: encryptedEmail, userId: encryptedUserId)))),
              `class`([Class.pf.components.button(color: .purple)])
              ],
              ["Click here to accept!"])
            ])
          ])
        ])
      ])
    ])
}

fileprivate extension Tagged where Tagged == EmailAddress {
  func hasDomain(_ domain: EnterpriseAccount.Domain) -> Bool {
    return self.rawValue.lowercased().hasSuffix("@\(domain.rawValue.lowercased())")
  }
}

private func redirectCurrentSubscribers<Z>(
  _ middleware: @escaping AppMiddleware<T2<User, Z>>
  ) -> AppMiddleware<T2<User, Z>> {

  return { conn in
    let user = get1(conn.data)
    guard let subscriptionId = user.subscriptionId
      else { return middleware(conn) }

    let hasActiveSubscription = Current.database.fetchSubscriptionById(subscriptionId)
      .mapExcept(requireSome)
      .bimap(const(unit), id)
      .flatMap { Current.stripe.fetchSubscription($0.stripeSubscriptionId) }
      .run
      .map { $0.right?.isRenewing ?? false }

    return hasActiveSubscription.flatMap {
      $0
        ? conn
          |> redirect(
            to: .account(.index),
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
