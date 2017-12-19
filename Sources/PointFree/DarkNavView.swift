import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude

let darkNavView = View<Database.User?> { currentUser in
  gridRow([`class`([newNavBarClass])], [
    gridColumn(sizes: [.mobile: 0, .desktop: 5], [
      div([])
      ]),

    gridColumn(sizes: [.mobile: 2], [
      div([`class`([Class.grid.center(.mobile)])], [
        a([href(path(to: .secretHome))], [
          img(base64: pointFreeDiamondLogoSvgBase64, mediaType: .image(.svg), alt: "", [])
          ])
        ])
      ]),

    gridColumn(
      sizes: [.mobile: 10, .desktop: 5],
      currentUser.map(loggedInNavItemsView.view) ?? loggedOutNavItemsView.view(nil)
    ),
    ])
}

private let newNavBarClass =
  Class.pf.colors.bg.purple150
    | Class.padding([.mobile: [.leftRight: 2, .topBottom: 3]])
    | Class.grid.middle(.mobile)
    | Class.grid.between(.mobile)

private let loggedInNavItemsView = View<Database.User?> { currentUser in
  ul([`class`([Class.type.list.reset, Class.grid.end(.mobile), Class.margin([.mobile: [.all: 0]])])], [
    li([`class`([Class.display.inline])], [
      a([href(path(to: .about)), `class`([Class.pf.colors.link.green, Class.padding([.mobile: [.right: 3]])])], ["About"])
      ]),
    li([`class`([Class.display.inline])], [
      a([href(path(to: .pricing(nil))), `class`([Class.pf.colors.link.green, Class.padding([.mobile: [.right: 3]])])], ["Subscribe"])
      ]),
    li([`class`([Class.display.inline])], [
      a([href(path(to: .account)), `class`([Class.pf.colors.link.green, Class.padding([.mobile: [.right: 3]])])], ["Account"])
      ]),
    ])
}

private let loggedOutNavItemsView = View<Database.User?> { currentUser in
  ul([`class`([Class.type.list.reset, Class.grid.end(.mobile), Class.margin([.mobile: [.all: 0]])])], [
    li([`class`([Class.display.inline])], [
      a([href(path(to: .about)), `class`([Class.pf.colors.link.green, Class.padding([.mobile: [.right: 3]])])], ["About"])
      ]),
    li([`class`([Class.display.inline])], [
      a([href(path(to: .pricing(nil))), `class`([Class.pf.colors.link.green, Class.padding([.mobile: [.right: 3]])])], ["Subscribe"])
      ]),
    li([`class`([Class.display.inline])], [
      gitHubLink(redirectRoute: .secretHome)
      ]),
    ])
}

private func gitHubLink(redirectRoute: Route) -> Node {
  return a(
    [
      href(path(to: .login(redirect: url(to: redirectRoute)))),
      `class`([Class.pf.components.buttons.white])
    ],
    [
      img(
        base64: gitHubSvgBase64(fill: "#000"),
        mediaType: .image(.svg),
        alt: "",
        [
          `class`([Class.margin([.mobile: [.right: 1]])]),
          style(margin(bottom: .px(-4))),
          width(20),
          height(20)]
      ),
      span(["Log in"])
    ]
  )
}

