import HttpPipeline
import Foundation
import Views
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let giftsIndexMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, Route, SubscriberState>,
  Data
>
= writeStatus(.ok)
>=> map(lower)
>>> respond(
  view: giftsLanding(episodeStats:),
  layoutData: { currentUser, currentRoute, subscriberState in
    let episodeStats = stats(forEpisodes: Current.episodes())

    return SimplePageLayoutData(
      currentRoute: currentRoute,
      currentSubscriberState: subscriberState,
      currentUser: currentUser,
      data: episodeStats,
      description: """
          TODO: Gift a subscription to a friend!
          """,
      //        extraHead: <#T##ChildOf<Tag.Head>#>,
      extraStyles: extraGiftLandingStyles <> testimonialStyle,
      //        image: <#T##String?#>,
      //        isGhosting: <#T##Bool#>,
      //        openGraphType: <#T##OpenGraphType#>,
      style: .base(.some(.minimal(.black))),
      title: "🎁 Gift Subscription"
      //        twitterCard: <#T##TwitterCard#>,
      //        usePrismJs: <#T##Bool#>
    )
  }
)
