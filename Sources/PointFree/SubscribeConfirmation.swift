import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import View
import Views

public let subscribeConfirmation: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, Route, SubscriberState>,
  Data
  > =
  requireAdmin
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: View(Views.subscriptionConfirmation),
      layoutData: { currentUser, currentRoute, subscriberState in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: currentUser,
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
    }
)
