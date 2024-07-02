import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

func collectionsIndexMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: "Point-Free: A video series exploring advanced programming topics in Swift.",
        title: "Point-Free: Collections"
      )
    ) {
      Collections()
    }
}
