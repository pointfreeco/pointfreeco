import Css
import Foundation
import FunctionalCss
import Html
import HttpPipeline
import PointFreeRouter
import Prelude
import Tuple
import Views

func routeNotFoundMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
) -> IO<Conn<ResponseEnded, Data>> {
  return
    conn.map { $0 .*. unit }
    |> writeStatus(.notFound)
    >=> map(lower)
    >>> respond(
      view: { _ in routeNotFoundView },
      layoutData: { _ in
        SimplePageLayoutData(
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
