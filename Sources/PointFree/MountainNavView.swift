import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Models
import Optics
import PointFreeRouter
import Styleguide
import Prelude
import View

let mountainNavView = View<(NavStyle.MountainsStyle, User?, SubscriberState, Route?)> { mountainsStyle, currentUser, subscriberState, currentRoute in

  menuAndLogoHeaderView.view((mountainsStyle, currentUser, subscriberState, currentRoute))
    + [
      gridRow([`class`([Class.grid.top(.mobile), Class.grid.between(.mobile), Class.padding([.mobile: [.top: 3], .desktop: [.top: 0]])])], [

        gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
          img(base64: heroMountainSvgBase64, type: .image(.svg), alt: "", [`class`([Class.size.width100pct])])
          ]),

        gridColumn(sizes: [.mobile: 2], [`class`([Class.position.z1])], [
          div([`class`([Class.type.align.center, Class.pf.type.body.leading]), style(margin(leftRight: .rem(-6)))], [
            .text(mountainsStyle.heroTagline)
            ])
          ]),

        gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
          img(
            base64: heroMountainSvgBase64,
            type: .image(.svg),
            alt: "",
            [`class`([Class.pf.components.reflectX, Class.size.width100pct])]
          )
          ]),
        ])
  ]
}

private let menuAndLogoHeaderView = View<(NavStyle.MountainsStyle, User?, SubscriberState, Route?)> { mountainsStyle, currentUser, subscriberState, currentRoute in

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
            headerLinks.view((mountainsStyle, currentUser, subscriberState, currentRoute))
          )
          ])
        ]),

      gridRow([`class`([Class.grid.center(.mobile), Class.padding([.mobile: [.topBottom: 2], .desktop: [.topBottom: 0]])])], [
        gridColumn(sizes: [:], [
          a([href(path(to: .home))], [
            img(
              base64: mountainsStyle.heroLogoSvgBase64,
              type: .image(.svg),
              alt: "",
              [`class`([Class.pf.components.heroLogo])]
            )
            ])
          ])
        ])
      ])
    ])
}

private let headerLinks = View<(NavStyle.MountainsStyle, User?, SubscriberState, Route?)> { mountainsStyle, currentUser, subscriberState, currentRoute -> [Node] in

  return [
    a(
      [href(path(to: .blog(.index))), `class`([navLinkClasses])],
      ["Blog"]
    ),

    subscriberState.isNonSubscriber
      ? a([href(path(to: .pricing(nil, expand: nil))), `class`([navLinkClasses])], ["Subscribe"])
      : nil,

    currentUser == nil
      ? gitHubLink(
        text: "Login",
        type: .black,
        href: path(to: .login(redirect: currentRoute.map(url(to:))))
        )
      : a([href(path(to: .account(.index))), `class`([Class.type.medium, Class.pf.colors.link.black])], ["Account"]),
    ]
    .compactMap(id)
}


let navLinkClasses =
  Class.type.medium
    | Class.pf.colors.link.black
    | Class.margin([.mobile: [.right: 2], .desktop: [.right: 3]])
