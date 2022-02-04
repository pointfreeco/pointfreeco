import HttpPipeline
import Foundation
import Views
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let giftPaymentMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple4<Gifts.Plan, User?, AppRoute, SubscriberState>,
  Data
>
= writeStatus(.ok)
>=> map(lower)
>>> respond(
  view: giftsPayment(plan:currentUser:stripeJs:stripePublishableKey:),
  layoutData: { giftPlan, currentUser, currentRoute, subscriberState in
    SimplePageLayoutData(
      currentRoute: currentRoute,
      currentSubscriberState: subscriberState,
      currentUser: currentUser,
      data: (giftPlan, currentUser, Current.stripe.js, Current.envVars.stripe.publishableKey),
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
