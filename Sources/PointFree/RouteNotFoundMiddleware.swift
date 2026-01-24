import Css
import Foundation
import FunctionalCss
import Html
import HttpPipeline
import PointFreeRouter
import Prelude
import StyleguideV2
import Tuple
import Views

func routeNotFoundMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.notFound)
    .respondV2(layoutData: SimplePageLayoutData(title: "Page not found", usePrismJs: true)) {
      NotFound()
    }
}

private struct NotFound: HTML {
  var body: some HTML {
    PageModule(title: "Page not found :(", theme: .content) {
      HTMLMarkdown(
        """
        ```swift
        func load(_ page: Page) -> Never
        ```
        """
      )
      .padding(.extraLarge)
      .inlineStyle("text-align", "center")
      .inlineStyle("width", "100%")
    }
  }
}
