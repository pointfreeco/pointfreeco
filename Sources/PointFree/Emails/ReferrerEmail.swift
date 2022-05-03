import FunctionalCss
import GitHub
import Html
import HtmlCssSupport
import PointFreeRouter
import Prelude
import Styleguide

let referralEmailView =
  simpleEmailLayout(referralEmailBody) <<< {
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You just got one month free!",
      preheader: "",
      template: .default(),
      data: $0
    )
  }

private func referralEmailBody(_: Prelude.Unit) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])], "You just got one month free!"),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            """
            Someone just subscribed with your referral code, which means you get one month of Point-Free for free! We've applied a credit of $18 to your account, which you should see reflected on \(.a(attributes: [.href(siteRouter.url(for: .account()))], "your account page")).
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
            """
            Thanks again for sharing Point-Free with your friends and colleagues!
            """
          )
        )
      )
    )
  )
}
