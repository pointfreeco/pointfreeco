import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude
import Tuple

let _navView = View<Tuple3<Database.User?, URLRequest, Prelude.Unit>> { ctx in
  []
}

let navView = View<RequestContext<Prelude.Unit>> { ctx in
  [
    gridRow([`class`([Class.pf.components.navBar, Class.grid.between(.xs)])], [
      gridColumn(
        sizes: [:],
        unpersonalizedNavItems.view(unit)
      ),

      gridColumn(
        sizes: [:],
        personalizedNavItems.view(ctx)
      ),

      ]),
    ]
}

let minimalNavView = View<Prelude.Unit> { _ in
  [
    gridRow([`class`([Class.pf.components.minimalNavBar])], [
      gridColumn(
        sizes: [:],
        unpersonalizedNavItems.view(unit)
      ),
      ]),
    ]
}

private let unpersonalizedNavItems = View<Prelude.Unit> { _ in
  ul([`class`([Class.type.list.reset, Class.margin.all(0)])], [
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .episodes(tag: nil))), `class`([Class.padding.leftRight(1)])], ["Videos"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href("#"), `class`([Class.padding.leftRight(1)])], ["Blog"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href("#"), `class`([Class.padding.leftRight(1)])], ["Books"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .about)), `class`([Class.padding.leftRight(1)])], ["About"])
      ]),
    ])
}

private let personalizedNavItems = View<RequestContext<Prelude.Unit>> { ctx in
  ctx.currentUser.map(loggedInNavItems.view)
    ?? loggedOutNavItems.view(ctx.currentRequest)
}

private let loggedInNavItems = View<Database.User> { user in

  ul([`class`([Class.type.list.reset, Class.margin.all(0)])], [
    li([`class`([Class.layout.inline])], [
      a([href("#"), `class`([Class.padding.leftRight(1)])], ["Account"])
      ]),

    li([`class`([Class.layout.inline])], [
      a([href(path(to: .logout)), `class`([Class.padding.leftRight(1)])], ["Logout"])
      ]),
    ])
}

private let loggedOutNavItems = View<URLRequest> { request in

  ul([`class`([Class.layout.right, Class.type.list.reset, Class.margin.all(0)])], [
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .login(redirect: request.url?.absoluteString))), `class`([Class.padding.leftRight(1)])],
        ["Login"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .pricing(unit))), `class`([Class.padding.leftRight(1)])],
        ["Subscribe"])
      ]),
    ])
}
