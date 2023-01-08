import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let giftsIndexMiddleware:
  Middleware<
    StatusLineOpen,
    ResponseEnded,
    Void,
    Data
  > =
    writeStatus(.ok)
    >=> respond(
      view: giftsLanding(episodeStats:),
      layoutData: {
        let episodeStats = stats(forEpisodes: Current.episodes())

        return SimplePageLayoutData(
          data: episodeStats,
          description: """
            Give the gift of Point-Free! Purchase a 3, 6, or 12 month subscription for a friend, colleague or loved one.
            """,
          extraStyles: extraGiftLandingStyles <> testimonialStyle,
          style: .base(.some(.minimal(.black))),
          title: "🎁 Point-Free Gift Subscription"
        )
      }
    )
