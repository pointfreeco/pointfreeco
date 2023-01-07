import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let giftPaymentMiddleware:
  Middleware<
    StatusLineOpen,
    ResponseEnded,
    Tuple4<Gifts.Plan, User?, SiteRoute, SubscriberState>,
    Data
  > =
    writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: giftsPayment(plan:currentUser:stripeJs:stripePublishableKey:),
      layoutData: { giftPlan, currentUser, currentRoute, subscriberState in
        @Dependency(\.stripe.js) var js
        @Dependency(\.envVars.stripe.publishableKey) var stripeKey

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (giftPlan, currentUser, js, stripeKey),
          description: """
            Give the gift of Point-Free! Purchase a \(giftPlan.monthCount) month subscription for a \
            friend or loved one.
            """,
          extraStyles: extraGiftLandingStyles <> testimonialStyle,
          style: .base(.some(.minimal(.black))),
          title: "🎁 Gift Subscription"
        )
      }
    )
