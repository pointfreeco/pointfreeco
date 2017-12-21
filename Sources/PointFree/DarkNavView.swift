import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude

let darkNavView = View<(Database.User?, Route?)> { currentUser, currentRoute in
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
      currentUser.map(loggedInNavItemsView.view) ?? loggedOutNavItemsView.view(currentRoute)
    ),
    ])
}

private let loggedInNavItemsView = View<Database.User> { currentUser in
  navItems(
    [
      aboutLinkView,
      currentUser.subscriptionId == nil ? subscribeLinkView : nil,
      accountLinkView
      ]
      .flatMap(id)
    )
    .view(unit)
}

private let loggedOutNavItemsView = navItems([
  aboutLinkView.contramap(const(unit)),
  subscribeLinkView.contramap(const(unit)),
  logInLinkView
  ])

private func navItems<A>(_ views: [View<A>]) -> View<A> {
  return View { a in
    ul([`class`([navListClass])],
       views
        .map { (curry(li)([`class`([navListItemClass])]) >>> pure) <¢> $0 }
        .concat()
        .view(a)
    )
  }
}

private let aboutLinkView = View<Prelude.Unit> { _ in
  a([href(path(to: .about)), `class`([navLinkClass])], ["About"])
}

private let subscribeLinkView = View<Prelude.Unit> { _ in
  a([href(path(to: .pricing(nil, nil))), `class`([navLinkClass])], ["Subscribe"])
}

private let accountLinkView = View<Prelude.Unit> { _ in
  a([href(path(to: .account)), `class`([navLinkClass])], ["Account"])
}

private let logInLinkView = View<Route?> { currentRoute in
  gitHubLink(text: "Log in", type: .white, redirectRoute: currentRoute)
}

private let navLinkClass =
  Class.pf.colors.link.green

private let navListItemClass =
  Class.padding([.mobile: [.left: 3]])
    | Class.display.inline

private let navListClass =
  Class.type.list.reset
    | Class.grid.end(.mobile)

private let newNavBarClass =
  Class.pf.colors.bg.purple150
    | Class.padding([.mobile: [.leftRight: 2, .topBottom: 3]])
    | Class.grid.middle(.mobile)
    | Class.grid.between(.mobile)
