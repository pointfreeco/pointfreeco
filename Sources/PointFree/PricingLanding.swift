import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let pricingLanding: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, Route, SubscriberState>,
  Data
  >
  = writeStatus(.ok)
    >=> map(lower)
    >>> _respond(
      view: Views.pricingLanding,
      layoutData: { currentUser, currentRoute, subscriberState in
        let episodeStats = stats(forEpisodes: Current.episodes())

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (
            currentUser,
            episodeStats,
            subscriberState
          ),
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
