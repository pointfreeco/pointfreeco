import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude

let mountainNavView = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in

  menuAndLogoHeaderView.view((currentUser, currentSubscriptionStatus, currentRoute))
    + [
      gridRow([`class`([Class.grid.top(.mobile), Class.grid.between(.mobile), Class.padding([.mobile: [.top: 3], .desktop: [.top: 0]])])], [

        gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
          img(base64: heroMountainSvgBase64, mediaType: .image(.svg), alt: "", [width(.pct(100))])
          ]),

        gridColumn(sizes: [.mobile: 2], [`class`([Class.position.z1])], [
          div([`class`([Class.type.align.center, Class.pf.type.body.leading]), style(margin(leftRight: .rem(-6)))], [
            "A new Swift video series exploring functional programming and more."
            ])
          ]),

        gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
          img(
            base64: heroMountainSvgBase64,
            mediaType: .image(.svg),
            alt: "",
            [width(.pct(100)), `class`([Class.pf.components.reflectX])]
          )
          ]),
        ])
  ]
}

private let menuAndLogoHeaderView = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in

  gridRow([`class`([Class.padding([.mobile: [.leftRight: 3, .top: 3, .bottom: 1], .desktop: [.leftRight: 4, .top: 4, .bottom: 4]]), Class.grid.top(.desktop), Class.grid.middle(.mobile), Class.grid.between(.mobile), Class.pf.components.blueGradient])], [

    gridColumn(sizes: [.mobile: 12], [
      gridRow([
        gridColumn(sizes: [.mobile: 0, .desktop: 6], [
          div([
            ])
          ]),
        gridColumn(sizes: [.mobile: 12, .desktop: 6], [
          div(
            [`class`([Class.grid.end(.mobile)])],
            headerLinks.view((currentUser, currentSubscriptionStatus, currentRoute))
          )
          ])
        ]),

      gridRow([`class`([Class.grid.center(.mobile), Class.padding([.mobile: [.topBottom: 2], .desktop: [.topBottom: 0]])])], [
        gridColumn(sizes: [:], [
          a([href(path(to: .home))], [
            img(
              base64: pointFreeHeroSvgBase64,
              mediaType: .image(.svg),
              alt: "",
              [`class`([Class.pf.components.heroLogo])]
            )
            ])
          ])
        ])
      ])
    ])
}

private let headerLinks = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in
  [
    a([href(path(to: .about)), `class`([Class.type.medium, Class.pf.colors.link.black, Class.margin([.mobile: [.right: 2], .desktop: [.right: 3]])])], ["About"]),

    currentSubscriptionStatus == .some(.active)
      ? nil
      : a([href(path(to: .pricing(nil))), `class`([Class.type.medium, Class.pf.colors.link.black, Class.margin([.mobile: [.right: 2], .desktop: [.right: 3]])])], ["Subscribe"]),

    currentUser == nil
      ? gitHubLink(text: "Login", type: .black, redirectRoute: currentRoute)
      : a([href(path(to: .account(.index))), `class`([Class.type.medium, Class.pf.colors.link.black])], ["Account"]),
    ]
    .flatMap(id)
}
