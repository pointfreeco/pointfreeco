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
  @Dependency(\.currentUser) var currentUser
  guard currentUser.hasAccess(to: .thePointFreeWay)
  else {
    return conn.redirect(to: .home)
  }

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        title: "The Point-Free Way"
      )
    ) {
      PointFreeWayLanding()
    }
}
