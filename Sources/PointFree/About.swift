import Css
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func aboutResponse(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          Point-Free is a video series that explores advanced topics in the Swift programming \
          language.
          """,
        title: "About Point-Free"
      )
    ) {
      AboutView()
    }
}
