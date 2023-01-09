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
    Gifts.Plan,
    Data
  > =
    writeStatus(.ok)
    >=> respond(
      view: giftsPayment(plan:stripeJs:stripePublishableKey:),
      layoutData: { giftPlan in
        @Dependency(\.stripe.js) var js
        @Dependency(\.envVars.stripe.publishableKey) var stripeKey

        return SimplePageLayoutData(
          data: (giftPlan, js, stripeKey),
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
