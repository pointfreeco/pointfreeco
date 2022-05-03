import FunctionalCss
import GitHub
import Html
import HtmlCssSupport
import PointFreeRouter
import Prelude
import Styleguide

let registrationEmailView =
  simpleEmailLayout(registrationEmailBody) <<< { user in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Thanks for signing up!",
      preheader: "",
      template: .default(),
      data: user
    )
  }

private func registrationEmailBody(user: GitHubUser) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])], "Thanks for signing up!"),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "You’re one step closer to our video series!"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
            """
            To get all that Point-Free has to offer, choose from one of our monthly or yearly plans by clicking
            the link below!
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(siteRouter.url(for: .pricingLanding)),
                .class([Class.pf.components.button(color: .purple)]),
              ],
              "Choose a subscription plan!"
            )
          )
        )
      )
    )
  )
}
