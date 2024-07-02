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
  let episodeStats = stats(forEpisodes: episodes())

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          Get full access to all \(episodeStats.allEpisodeCount) videos on Point-Free. Choose from \
          a variety of plans, including personal, team and enterprise subscriptions.
          """,
        title: "Point-Free: Subscribe Today"
      )
    ) {
      PricingV2()
    }
}
