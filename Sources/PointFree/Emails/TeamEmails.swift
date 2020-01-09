import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

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

let youHaveBeenRemovedEmailView = simpleEmailLayout(youHaveBeenRemovedEmailBody) <<< { removalType in
  SimpleEmailLayoutData(
    user: nil,
    newsletter: nil,
    title: "You have been removed from \(removalType.displayName)’s Point-Free team",
    preheader: "",
    template: .default,
    data: removalType
  )
}

private func youHaveBeenRemovedEmailBody(removalType: RemovalType) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])],
            "Team removal"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            """
            You have been removed from \(removalType.displayName)’s Point-Free team, which means you no longer
            have access to full episodes and transcripts. If you wish to subscribe to an individual plan,
            click the link below!
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(url(to: .pricingLanding)),
                .class([Class.pf.components.button(color: .purple)])
              ],
              "See subscription plans"
            )
          )
        )
      )
    )
  )
}

let teammateRemovedEmailView = simpleEmailLayout(teammateRemovedEmailBody) <<< { teamOwner, teammate in
  SimpleEmailLayoutData(
    user: nil,
    newsletter: nil,
    title: "Your teammate \(teammate.displayName) has been removed",
    preheader: "",
    template: .default,
    data: (teamOwner, teammate)
  )
}

private func teammateRemovedEmailBody(teamOwner: User, teammate: User) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])],
            "Team removal"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            """
            You have removed \(teammate.displayName) from your Point-Free team, which means they no longer
            have access to full episodes and transcripts. You can add them back anytime from your account
            settings.
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(url(to: .account(.index))),
                .class([Class.pf.components.button(color: .purple)])
              ],
              "Account settings"
            )
          )
        )
      )
    )
  )
}
