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
  Tuple4<User?, Route, SubscriberState, Pricing.Lane>,
  Data
  > =
  requireAdmin
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: View(Views.subscriptionConfirmation),
      layoutData: { currentUser, currentRoute, subscriberState, lane in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (
            lane,
            currentUser,
            Current.stripe.js,
            Current.envVars.stripe.publishableKey.rawValue
          ),
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
    }
)
