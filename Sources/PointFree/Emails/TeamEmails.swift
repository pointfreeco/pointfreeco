import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import Prelude
import Styleguide
import View

enum RemovalType {
  case teamOwner(User)
  case enterpriseAccount(EnterpriseAccount)

  var displayName: String {
    switch self {
    case let .teamOwner(owner):
      return owner.displayName
    case let .enterpriseAccount(account):
      return account.companyName
    }
  }
}

let youHaveBeenRemovedEmailView = simpleEmailLayout(youHaveBeenRemovedEmailBody)
  .contramap { removalType in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You have been removed from \(removalType.displayName)’s Point-Free team",
      preheader: "",
      template: .default,
      data: removalType
    )
}

private let youHaveBeenRemovedEmailBody = View<RemovalType> { removalType in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["Team removal"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            .text("""
              You have been removed from \(removalType.displayName)’s Point-Free team, which means you no longer
              have access to full episodes and transcripts. If you wish to subscribe to an individual plan,
              click the link below!
              """)
            ]),

          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .pricing(nil, expand: nil))),
              `class`([Class.pf.components.button(color: .purple)])
              ],
              ["See subscription plans"])
            ])
          ])
        ])
      ])
    ])
}

let teammateRemovedEmailView = simpleEmailLayout(teammateRemovedEmailBody)
  .contramap { teamOwner, teammate in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your teammate \(teammate.displayName) has been removed",
      preheader: "",
      template: .default,
      data: (teamOwner, teammate)
    )
}

private let teammateRemovedEmailBody = View<(User, User)> { teamOwner, teammate in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["Team removal"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            .text("""
              You have removed \(teammate.displayName) from your Point-Free team, which means they no longer
              have access to full episodes and transcripts. You can add them back anytime from your account
              settings.
              """)
            ]),

          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .account(.index))),
              `class`([Class.pf.components.button(color: .purple)])
              ],
              ["Account settings"])
            ])
          ])
        ])
      ])
    ])
}
