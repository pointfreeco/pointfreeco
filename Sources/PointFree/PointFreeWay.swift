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
        image: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/28d2f776-ab34-449a-6852-18f038942500/public",
        title: "The Point-Free Way"
      )
    ) {
      PointFreeWayLanding()
    }
}
