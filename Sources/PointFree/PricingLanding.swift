import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import View
import Views

public let pricingLanding: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple6<User?, AllEpisodeCount, EpisodeHourCount, FreeEpisodeCount, Route, SubscriberState>,
  Data
  >
  = writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: Views.pricingLanding,
      layoutData: { currentUser, allEpisodeCount, episodeHourCount, freeEpisodeCount, currentRoute, subscriberState in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (allEpisodeCount, currentUser, episodeHourCount, freeEpisodeCount, subscriberState),
          description: """
Get full access to all \(allEpisodeCount) videos on Point-Free. Choose from a variety of plans, including
personal, team and enterprise subscriptions.
""",
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
    }
)
