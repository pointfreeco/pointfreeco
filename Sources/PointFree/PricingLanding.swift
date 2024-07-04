import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public func pricingMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.episodes) var episodes
  let stats = EpisodesStats()

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          Get full access to all \(stats.allEpisodes) videos on Point-Free. Choose from a variety \
          of plans, including personal, team, and enterprise subscriptions.
          """,
        title: "Point-Free: Subscribe Today"
      )
    ) {
      PricingLanding()
    }
}
