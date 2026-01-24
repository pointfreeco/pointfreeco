import Dependencies
import EnvVars
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Views

public func giftPaymentMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  plan: Gifts.Plan
) -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respond(
      view: giftsPayment(plan:stripeJs:stripePublishableKey:),
      layoutData: {
        @Dependency(\.stripe.js) var js
        @Dependency(\.envVars.stripe.publishableKey) var stripeKey

        return SimplePageLayoutData(
          data: (plan, js, stripeKey),
          description: """
            Give the gift of Point-Free! Purchase a \(plan.monthCount) month subscription for a \
            friend or loved one.
            """,
          extraStyles: extraGiftLandingStyles <> testimonialStyle,
          style: .base(.some(.minimal(.black))),
          title: "🎁 Gift Subscription"
        )
      }
    )
}
