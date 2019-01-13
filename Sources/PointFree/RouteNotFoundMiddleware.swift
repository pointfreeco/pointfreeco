import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import Tuple
import View

let routeNotFoundMiddleware =
  currentUserMiddleware
    >=> currentSubscriptionMiddleware
    >=> writeStatus(.notFound)
    >=> map(lower)
    >>> respond(
      view: routeNotFoundView,
      layoutData: { subscription, currentUser in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: unit,
          title: "Page not found"
        )
    }
)

private let routeNotFoundView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.grid.center(.mobile)])], [
    gridColumn(sizes: [.mobile: 6], [
      div([style(padding(topBottom: .rem(12)))], [
        h5([`class`([Class.pf.type.responsiveTitle5])], ["Page not found :("]),
        pre([
          code([`class`([Class.pf.components.code(lang: "swift")])], [
            "f: (Page) -> Never"
            ])
          ])
        ])
      ])
    ])
}
