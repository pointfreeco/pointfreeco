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
  ul([`class`([navListClass])], [
    li([`class`([navListItemClass])], [
      a([href(path(to: .about)), `class`([navLinkClass])], ["About"])
      ]),
    li([`class`([navListItemClass])], [
      a([href(path(to: .pricing(nil))), `class`([navLinkClass])], ["Subscribe"])
      ]),
    li([`class`([navListItemClass])], [
      a([href(path(to: .account)), `class`([navLinkClass])], ["Account"])
      ]),
    ])
}

private let loggedOutNavItemsView = View<Database.User?> { currentUser in
  ul([`class`([navListClass])], [
    li([`class`([navListItemClass])], [
      a([href(path(to: .about)), `class`([navLinkClass])], ["About"])
      ]),
    li([`class`([navListItemClass])], [
      a([href(path(to: .pricing(nil))), `class`([navLinkClass])], ["Subscribe"])
      ]),
    li([`class`([navListItemClass])], [
      gitHubLink(text: "Log in", type: .white, redirectRoute: .secretHome)
      ]),
    ])
}

private let navLinkClass =
  Class.pf.colors.link.green

private let navListItemClass =
  Class.padding([.mobile: [.left: 3]])
    | Class.display.inline

private let navListClass =
  Class.type.list.reset
    | Class.grid.end(.mobile)
