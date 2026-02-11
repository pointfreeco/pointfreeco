import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public func pricingMiddleware(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  @Dependency(\.episodes) var episodes
  let stats = EpisodesStats()

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          Get full access to the Point-Free Way AI skill documents, as well as \
          \(stats.allEpisodes) videos covering advanced Swift topics. Choose from a variety of \
          plans, including personal, team, and enterprise memberships.
          """,
        title: "Join Point-Free Today"
      )
    ) {
      PricingLanding()
    }
}
