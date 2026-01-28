import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func pointFreeWayMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          AI skill documents to best leverage Point-Free's open source libraries and embrace \
          the concepts and best patterns championed by Point-Free for years.
          """,
        title: "The Point-Free Way"
      )
    ) {
      PointFreeWayLanding()
    }
}
