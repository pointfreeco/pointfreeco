import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func betasMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  guard currentUser.hasAccess(to: .betas) else {
    return routeNotFoundMiddleware(conn)
  }
  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          Get early access to the next generation of Point-Free libraries. Join private betas \
          for projects we're actively developing and help shape them before they go public.
          """,
        title: "Private Betas"
      )
    ) {
      BetasLanding()
    }
}
