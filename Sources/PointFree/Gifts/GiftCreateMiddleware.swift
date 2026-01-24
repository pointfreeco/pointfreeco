import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Stripe
import Views

struct GiftCreateResponse: Encodable {
  var clientSecret: PaymentIntent.ClientSecret
}
struct GiftCreateError: Encodable {
  var errorMessage: String
}

func giftCreateMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  formData: GiftFormData
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.calendar) var calendar
  @Dependency(\.database) var database
  @Dependency(\.date.now) var now
  @Dependency(\.stripe) var stripe

  guard let plan = Gifts.Plan.init(monthCount: formData.monthsFree)
  else {
    return conn.redirect(to: .gifts()) {
      $0.flash(.notice, "Unknown gift option.")
    }
  }

  let deliverAt = formData.deliverAt
    .flatMap {
      calendar.startOfDay(for: $0) <= calendar.startOfDay(for: now)
        ? nil
        : $0
    }

  do {
    @Dependency(\.envVars.yearlyGiftCoupon) var yearlyGiftCoupon
    var paymentIntent = try await stripe.createPaymentIntent(
      amount: plan.amount,
      currency: .usd,
      description: "Gift subscription: \(plan.monthCount) months",
      paymentMethodID: formData.paymentMethodID,
      receiptEmail: formData.fromEmail.rawValue,
      statementDescriptorSuffix: "Gift Subscription"
    )
    paymentIntent = try await stripe.confirmPaymentIntent(id: paymentIntent.id)
    _ = try await database.createGift(
      coupon: formData.monthsFree == 12 ? yearlyGiftCoupon : nil,
      deliverAt: deliverAt,
      fromEmail: formData.fromEmail,
      fromName: formData.fromName,
      message: formData.message,
      monthsFree: formData.monthsFree,
      stripePaymentIntentId: paymentIntent.id,
      toEmail: formData.toEmail,
      toName: formData.toName
    )
  } catch {
    return conn.redirect(to: .gifts()) {
      $0.flash(.notice, "Unknown error with our payment processor")
    }
  }

  let message: String
  if let deliverAt = formData.deliverAt {
    message = """
      Your gift will be delivered to \(formData.toEmail.rawValue) on \
      \(monthDayYearFormatter.string(from: deliverAt)).
      """
  } else {
    message = """
      Your gift has been delivered to \(formData.toEmail.rawValue).
      """
  }
  return conn.redirect(to: .gifts()) {
    $0.flash(.notice, message)
  }
}
