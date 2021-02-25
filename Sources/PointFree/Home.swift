import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

let homeMiddleware: M<Tuple3<User?, SubscriberState, Route?>> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: homeView(currentDate:currentUser:subscriberState:episodes:date:emergencyMode:),
      layoutData: { (currentUser: User?, subscriberState: SubscriberState, currentRoute: Route?) in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (Current.date(), currentUser, subscriberState, Current.episodes(), Current.date, Current.envVars.emergencyMode),
          extraStyles: markdownBlockStyles,
          openGraphType: .website,
          style: .base(.mountains(.main)),
          title: "Point-Free: A video series on functional programming and the Swift programming language.",
          twitterCard: .summaryLargeImage
        )
    }
)
