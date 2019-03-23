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
  = filterMap(over2(fetchEnterpriseAccount) >>> sequence2 >>> map(require2), or: redirect(to: .home))
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
  Tuple3<User?, EnterpriseAccount.Domain, EnterpriseRequest>,
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

let enterpriseAcceptInviteMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, EnterpriseAccount.Domain, Encrypted<String>>,
  Data
  >
  = filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(validateSignature >>> pure, or: redirect(to: .home))
    // insert into enterprise emails
//    <<< filterMap(verifyDomain >>> pure, or: redirect(to: .home))
    // verify requester id == current user id
    // fetch enterprise account
    // link user to enterprise account

    <| redirect(to: .account(.index))

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

private func verifyDomain<A, Z>(
  _ data: T4<A, EnterpriseAccount.Domain, EnterpriseRequest, Z>
  ) -> T4<A, EnterpriseAccount.Domain, EnterpriseRequest, Z>? {

  let (domain, request) = (get2(data), get3(data))

  return request.email.hasDomain(domain)
    ? data
    : nil
}

private func sendEnterpriseInvitation<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<User, EnterpriseAccount, Z>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T3<User, EnterpriseAccount, Z>, Data> {

  return { conn in
    let (user, account) = (get1(conn.data), get2(conn.data))

    if !user.email.hasDomain(account.domain) {
      fatalError("TODO")
    } else if let signature = Encrypted(user.email.rawValue, with: Current.envVars.appSecret) {
      sendEmail(
        to: [user.email],
        subject: "You’re invited to join the \(account.companyName) team on Point-Free",
        content: inj2(enterpriseInviteEmailView.view((account, signature)))
        )
        .run
        .parallel
        .run({ _ in })
    } else {

    }

    return conn |> middleware
  }
}

private func validateSignature<A, Z>(
  data: T4<A, EnterpriseAccount.Domain, Encrypted<String>, Z>
  ) -> T4<A, EnterpriseAccount.Domain, EnterpriseRequest, Z>? {

  func sequence3<A, B, C, Z>(_ tuple: T4<A, B, C?, Z>) -> T4<A, B, C, Z>? {
    return get3(tuple).map { get1(tuple) .*. get2(tuple) .*. $0 .*. rest(tuple) }
  }

  // TODO: encrypt domain, user id and email
  // save email in a table somewhere

  return sequence3(
    data |> over3 {
      $0.decrypt(with: Current.envVars.appSecret)
        .map(EmailAddress.init(rawValue:))
        .map(EnterpriseRequest.init(email:))
    }
  )
}

func fetchEnterpriseAccount(_ domain: EnterpriseAccount.Domain) -> IO<EnterpriseAccount?> {
  return Current.database.fetchEnterpriseAccountForDomain(domain)
    .mapExcept(requireSome)
    .run
    .map(^\.right)
}

private func enterpriseView(_ currentUser: User?, _ account: EnterpriseAccount) -> [Node] {
  let loggedOutView = [
    p(
      [`class`([Class.pf.colors.fg.green])],
      ["Log in to gain access to every episode of ", pointFreeRaw, "."]
    ),
    gitHubLink(
      text: "Sign in with GitHub",
      type: .white,
      href: path(to: .login(redirect: url(to: .enterprise(.landing(account.domain)))))
    ),
  ]

  let loggedInView = [
    p(
      [`class`([Class.pf.colors.fg.green])],
      ["Enter your company email address to gain access to every episode of ", pointFreeRaw, "."]
    ),
    gridRow([`class`([Class.padding([.mobile: [.bottom: 3]]), Class.margin([.mobile: [.top: 2]])])], [
      gridColumn(sizes: [.mobile: 12], [], [
        form(
          [
            action(path(to: .enterprise(.requestInvite(account.domain, .init(email: ""))))),
            method(.post),
            ],
          [
            gridRow([`class`([Class.padding([.mobile: [.bottom: 3]]), Class.margin([.mobile: [.top: 4]]), Class.flex.flex, Class.flex.items.baseline])], [
              gridColumn(sizes: [.mobile: 8], [], [
                input(
                  [
                    `class`([blockInputClass]),
                    name(EnterpriseRequest.CodingKeys.email.rawValue),
                    placeholder("blob@\(account.domain)"),
                    type(.email),
                    ]),
                ]),
              gridColumn(sizes: [.mobile: 4], [], [
                button(
                  [`class`([Class.pf.components.button(color: .white), Class.margin([.mobile: [.left: 1]])])],
                  ["Request Access"])
                ]),
              ]),
            ]),
        ]),
      ]),
    ]

  return [
    gridRow([`class`([enterpriseRowClass])], [
      gridColumn(sizes: [.mobile: 12, .desktop: 7], [], [
        div([
          h2(
            [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle2])],
            [pointFreeRaw, " 🤝 ", .text(account.companyName)]
          ),
          ] + (currentUser == nil ? loggedOutView : loggedInView))
        ]),
      ]),
  ]
}

private let pointFreeRaw = Node.raw("Point&#8209;Free")

private let enterpriseRowClass =
  Class.pf.colors.bg.purple150
    | Class.grid.center(.mobile)
    | Class.padding([.mobile: [.topBottom: 3, .leftRight: 2], .desktop: [.topBottom: 4, .leftRight: 0]])

let enterpriseInviteEmailView = simpleEmailLayout(enterpriseInviteEmailBodyView)
  .contramap { account, signature in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You’re invited to join the \(account.companyName) team on Point-Free",
      preheader: "You’re invited to join the \(account.companyName) team on Point-Free.",
      template: .default,
      data: (account, signature)
    )
}

private let enterpriseInviteEmailBodyView = View<(EnterpriseAccount, Encrypted<String>)> { account, signature in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["You’re invited!"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "You’re invited to join the ", .text(account.companyName), " team on Point-Free a video series ",
            "about functional programming and the Swift programming language. To accept, simply click the ",
            "link below!"
            ]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .enterprise(.acceptInvite(account.domain, signature)))),
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
