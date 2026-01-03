import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func pointFreeWayMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        title: "The Point-Free Way"
      )
    ) {
      PointFreeWayLanding()
    }
}
