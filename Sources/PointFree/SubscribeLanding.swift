import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import View
import Views

public let subscribeLanding: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, SubscriberState, Route>,
  Data
  > =
//  requireAdmin
//    <|
    writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: View(Views.subscribeLanding),
      layoutData: { currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (currentUser, subscriberState),
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
    }
)
