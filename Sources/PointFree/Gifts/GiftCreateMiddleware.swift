import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import Views

struct GiftCreateResponse: Encodable {
  var clientSecret: PaymentIntent.ClientSecret
}
struct GiftCreateError: Encodable {
  var errorMessage: String
}

func giftCreateMiddleware(
  _ conn: Conn<StatusLineOpen, GiftFormData>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.calendar) var calendar
  @Dependency(\.database) var database
  @Dependency(\.date.now) var now
  @Dependency(\.stripe) var stripe

  let giftFormData = conn.data
  guard let plan = Gifts.Plan(rawValue: giftFormData.plan)
  else {
    return conn
      |> redirect(to: .gifts(), headersMiddleware: flash(.notice, "Unknown gift option."))
  }

  let deliverAt = giftFormData.deliverAt
    .flatMap {
      calendar.startOfDay(for: $0) <= calendar.startOfDay(for: now)
        ? nil
        : $0
    }

  return EitherIO<_, PaymentIntent> {
    @Dependency(\.envVars.yearlyGiftCoupon) var yearlyGiftCoupon
    var paymentIntent = try await stripe.createPaymentIntent(
      amount: plan.amount,
      currency: .usd,
      description: "Gift membership: \(plan.laneTitle)",
      paymentMethodID: giftFormData.paymentMethodID,
      receiptEmail: giftFormData.fromEmail.rawValue,
      statementDescriptorSuffix: "Gift Membership"
    )
    paymentIntent = try await stripe.confirmPaymentIntent(id: paymentIntent.id)
    _ = try await database.createGift(
      coupon: plan.monthCount == 12 ? yearlyGiftCoupon : nil,
      deliverAt: deliverAt,
      fromEmail: giftFormData.fromEmail,
      fromName: giftFormData.fromName,
      message: giftFormData.message,
      monthsFree: plan.monthCount,
      plan: plan.pricingPlan,
      stripePaymentIntentId: paymentIntent.id,
      toEmail: giftFormData.toEmail,
      toName: giftFormData.toName
    )
    return paymentIntent
  }
  .run
  .flatMap { errorOrPaymentIntent in
    switch errorOrPaymentIntent {
    case .left(let error):
      let message =
        (error as? StripeErrorEnvelope).map(\.error.message)
        ?? "Unknown error with our payment processor."
      return conn
        |> redirect(
          to: .gifts(),
          headersMiddleware: flash(.error, message)
        )

    case .right:
      let message: String
      if let deliverAt = giftFormData.deliverAt {
        message = """
          Your gift will be delivered to \(giftFormData.toEmail.rawValue) on \
          \(monthDayYearFormatter.string(from: deliverAt)).
          """
      } else {
        message = """
          Your gift has been delivered to \(giftFormData.toEmail.rawValue).
          """
      }
      return conn |> redirect(to: .gifts(), headersMiddleware: flash(.notice, message))
    }
  }
}
