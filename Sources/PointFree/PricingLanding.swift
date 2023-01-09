import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let pricingLanding:
  Middleware<
    StatusLineOpen,
    ResponseEnded,
    Void,
    Data
  > =
    writeStatus(.ok)
    >=> respond(
      view: Views.pricingLanding,
      layoutData: {
        @Dependency(\.episodes) var episodes

        let episodeStats = stats(forEpisodes: episodes())

        return SimplePageLayoutData(
          data: episodeStats,
          description: """
            Get full access to all \(episodeStats.allEpisodeCount) videos on Point-Free. Choose from a variety of plans, including
            personal, team and enterprise subscriptions.
            """,
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
      }
    )
