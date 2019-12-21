import FunctionalCss
import GitHub
import Html
import HtmlCssSupport
import Optics
import PointFreeRouter
import Prelude
import Styleguide

let registrationEmailView = simpleEmailLayout(registrationEmailBody) <<< { user in
  SimpleEmailLayoutData(
    user: nil,
    newsletter: nil,
    title: "Thanks for signing up!",
    preheader: "",
    template: .default,
    data: user
  )
}

private func registrationEmailBody(user: GitHubUser) -> Node {
  return .emailTable(
    attribute: [.style(contentTableStyles)],
    .tr(
      .td(
        attribute: [.valign(.top)],
        .div(
          attribute: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attribute: [.class([Class.pf.type.responsiveTitle3])], "Thanks for signing up!"),
          .p(
            attribute: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "You’re one step closer to our video series!"
          ),
          .p(
            attribute: [.class([Class.padding([.mobile: [.bottom: 2]])])],
            """
            To get all that Point-Free has to offer, choose from one of our monthly or yearly plans by clicking
            the link below!
            """
          ),
          .p(
            attribute: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attribute: [
                .href(url(to: .pricingLanding)),
                .class([Class.pf.components.button(color: .purple)])
              ],
              "Choose a subscription plan!"
            )
          )
        )
      )
    )
  )
}
