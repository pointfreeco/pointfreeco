import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude

let lightNavView = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in
  gridRow([`class`([newNavBarClass])], [
    gridColumn(sizes: [.mobile: 0, .desktop: 5], [
      div([])
      ]),

    gridColumn(sizes: [.mobile: 2], [
      div([`class`([Class.grid.center(.mobile)])], [
        a([href(path(to: .secretHome))], [
          img(base64: pointFreeTextLogoSvgBase64(color: "#121212"), mediaType: .image(.svg), alt: "", [])
          ])
        ])
      ]),

    gridColumn(
      sizes: [.mobile: 10, .desktop: 5],
      currentUser.map { loggedInNavItemsView.view(($0, currentSubscriptionStatus)) }
        ?? loggedOutNavItemsView.view(currentRoute)
    ),
    ])
}

private let loggedInNavItemsView = View<(Database.User, Stripe.Subscription.Status?)> { currentUser, currentSubscriptionStatus in
  navItems(
    [
      aboutLinkView,
      currentSubscriptionStatus == .some(.active) ? nil : subscribeLinkView,
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
  a([href(path(to: .account(.index))), `class`([navLinkClass])], ["Account"])
}

private let logInLinkView = View<Route?> { currentRoute in
  gitHubLink(text: "Log in", type: .black, redirectRoute: currentRoute)
}

private let navLinkClass =
  Class.pf.colors.link.black

private let navListItemClass =
  Class.padding([.mobile: [.left: 3]])
    | Class.display.inline

private let navListClass =
  Class.type.list.reset
    | Class.grid.end(.mobile)

private let newNavBarClass =
  Class.pf.colors.bg.blue900
    | Class.padding([.mobile: [.leftRight: 2, .topBottom: 3]])
    | Class.grid.middle(.mobile)
    | Class.grid.between(.mobile)
