import Css
import FunctionalCss
import Foundation
import Html
import HttpPipeline
import PointFreeRouter
import Prelude
import Tuple

func routeNotFoundMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<ResponseEnded, Data>> {
  return
    conn.map { $0 .*. unit }
      |> currentUserMiddleware
      >=> writeStatus(.notFound)
      >=> map(lower)
      >>> _respond(
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

private let routeNotFoundView = Node.gridRow(
  attributes: [.class([Class.grid.center(.mobile)])],
  .gridColumn(
    sizes: [.mobile: 6],
    .div(
      attributes: [.style(padding(topBottom: .rem(12)))],
      .h5(attributes: [.class([Class.pf.type.responsiveTitle5])], "Page not found :("),
      .pre(
        .code(attributes: [.class([Class.pf.components.code(lang: "swift")])], "f: (Page) -> Never")
      )
    )
  )
)
