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
import Tuple
import UrlFormEncoding
import View
import Views

let enterpriseLandingResponse: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple2<User?, EnterpriseAccount.Domain>,
  Data
  >
  = filterMap(
    over2(fetchEnterpriseAccount) >>> sequence2 >>> map(require2),
    or: redirect(
      to: .home,
      headersMiddleware: flash(.warning, "That enterprise account does not exist.")
    )
    )
    <<< validateMembership
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: View(enterpriseView),
      layoutData: { user, enterpriseAccount in
        SimplePageLayoutData(
          currentUser: user,
          data: (user, enterpriseAccount),
          style: .base(.minimal(.dark)),
          title: "Point-Free 🤝 \(enterpriseAccount.companyName)"
        )
    }
)

let enterpriseRequestMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, EnterpriseAccount.Domain, EnterpriseRequestFormData>,
  Data
  >
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
    <<< filterMap(
      validateInvitation >>> pure,
      or: invalidInvitationLinkMiddleware
    )
    <<< filterMap(
      over2(fetchEnterpriseAccount) >>> sequence2 >>> map(require2),
      or: redirect(
        to: .home,
        headersMiddleware: flash(.warning, "That enterprise account does not exist.")
      )
    )
    // insert into enterprise emails
    // link user to enterprise account
    <| redirect(to: .account(.index))

private func invalidInvitationLinkMiddleware<A, Z>(
  _ conn: Conn<StatusLineOpen, T3<A, EnterpriseAccount.Domain, Z>>
  ) -> IO<Conn<ResponseEnded, Data>> {
  return conn
    |> redirect(
      to: pointFreeRouter.path(to: .enterprise(.landing(get2(conn.data)))),
      headersMiddleware: flash(.notice, "Something is wrong with your invitation link. Please try again.")
  )
}

private func validateMembership<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<User?, EnterpriseAccount, Z>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T3<User?, EnterpriseAccount, Z>, Data> {

  return { conn in
    let (user, account) = (get1(conn.data), get2(conn.data))

    if user?.subscriptionId == account.subscriptionId {
      return conn |> redirect(
        to: .account(.index),
        headersMiddleware: flash(.notice, "You're already enrolled in \(account.companyName)'s subscription! 🙌")
      )
    } else {
      return middleware(conn)
    }
  }
}

private func validateInvitation(
  _ data: Tuple4<User, EnterpriseAccount.Domain, Encrypted<String>, Encrypted<String>>
  ) -> Tuple4<User, EnterpriseAccount.Domain, EmailAddress, User.Id>? {

  let (user, domain, encryptedEmail, encryptedUserId) = lower(data)

  // Make sure email decrypts correctly
  guard let email = encryptedEmail.decrypt(with: Current.envVars.appSecret)
    .map(EmailAddress.init(rawValue:))
    else { return nil }

  // Make sure email address is on the same domain as the enterprise account
  guard email.hasDomain(domain)
    else { return nil }

  // Make sure user id decrypts correctly.
  guard let userId = encryptedUserId.decrypt(with: Current.envVars.appSecret)
    .flatMap(UUID.init(uuidString:))
    .map(User.Id.init(rawValue:))
    else { return nil }

  // Validates that the userId encrypted into the invite link is the same as the email accepting the invitation.
  guard userId == user.id
    else { return nil }

  return .some(user .*. domain .*. email .*. userId .*. unit)
}

private func sendEnterpriseInvitation<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T4<User, EnterpriseAccount, EnterpriseRequestFormData, Z>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T4<User, EnterpriseAccount, EnterpriseRequestFormData, Z>, Data> {

  return { conn in
    let (user, account, request) = (get1(conn.data), get2(conn.data), get3(conn.data))

    if user.email.hasDomain(account.domain) {
      fatalError("TODO: User's email is already from that domain, so we can just switch them to enterprise immediately.")
    } else if !request.email.hasDomain(account.domain) {
      return conn
        |> redirect(
          to: pointFreeRouter.path(to: .enterprise(.landing(account.domain))),
          headersMiddleware: flash(.error, "The email you entered does not come from the @\(account.domain) domain.")
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
          headersMiddleware: flash(.warning, "Something went wrong. Please try again or contact <support@pointfree.co>.")
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
