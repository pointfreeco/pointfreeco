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
  > =
  requireAdmin
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: View(Views.pricingLanding),
      layoutData: { currentUser, allEpisodeCount, episodeHourCount, freeEpisodeCount, currentRoute, subscriberState in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (allEpisodeCount, currentUser, episodeHourCount, freeEpisodeCount, subscriberState),
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
    }
)
