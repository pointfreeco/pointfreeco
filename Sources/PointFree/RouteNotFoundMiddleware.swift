import Css
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import PointFreeRouter
import Prelude
import Styleguide
import Tuple

func routeNotFoundMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<ResponseEnded, Data>> {
  return
    conn.map { $0 .*. unit }
      |> currentUserMiddleware
      >=> writeStatus(.notFound)
      >=> map(lower)
      >>> respond(
        view: { _ in routeNotFoundView },
        layoutData: { currentUser, _ in
          SimplePageLayoutData(
            currentUser: currentUser,
            data: unit,
            title: "Page not found"
          )
      }
  )
}

private let routeNotFoundView = [
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
]
