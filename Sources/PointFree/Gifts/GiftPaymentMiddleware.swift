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
        SimplePageLayoutData(
          data: (giftPlan, Current.stripe.js, Current.envVars.stripe.publishableKey),
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
