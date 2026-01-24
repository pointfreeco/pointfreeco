import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public func giftsIndexMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          Give the gift of Point-Free! Purchase a 3, 6, or 12 month subscription for a friend, \
          colleague or loved one.
          """,
        title: "🎁 Point-Free Gift Subscription"
      )
    ) {
      GiftsV2()
    }
}
