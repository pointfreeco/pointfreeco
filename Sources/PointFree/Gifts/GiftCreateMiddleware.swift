import Either
import HttpPipeline
import Foundation
import Views
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
) -> IO<Conn<HeadersOpen, Either<GiftCreateError, GiftCreateResponse>>> {

  let giftFormData = conn.data
  guard let plan = Gifts.Plan.init(monthCount: giftFormData.monthsFree)
  else {
    return conn.map(const(.left(.init(errorMessage: "Unknown gift option."))))
    |> writeStatus(.badRequest)
  }

  return Current.stripe.createPaymentIntent(
    .init(
      amount: plan.amount,
      currency: .usd,
      description: "Gift subscription: \(plan.monthCount) months",
      receiptEmail: giftFormData.fromEmail.rawValue,
      statementDescriptorSuffix: "Gift Subscription"
    )
  )
    .flatMap { paymentIntent in
      Current.database.createGift(
        .init(
          deliverAt: giftFormData.deliverAt,
          fromEmail: giftFormData.fromEmail,
          fromName: giftFormData.fromName,
          message: giftFormData.message,
          monthsFree: giftFormData.monthsFree,
          stripePaymentIntentId: paymentIntent.id,
          toEmail: giftFormData.toEmail,
          toName: giftFormData.toName
        )
      )
        .map { _ in paymentIntent }
    }
    .run
    .flatMap { errorOrPaymentIntent in
      switch errorOrPaymentIntent {
      case .left:
        return conn.map(const(.left(.init(errorMessage: "Unknown error with our payment processor"))))
        |> writeStatus(.badRequest)

      case let .right(paymentIntent):
        return conn.map(const(.right(.init(clientSecret: paymentIntent.clientSecret))))
        |> writeStatus(.ok)
      }
    }
}

func giftConfirmationMiddleware(
  conn: Conn<StatusLineOpen, GiftFormData>
) -> IO<Conn<ResponseEnded, Data>> {
  let formData = conn.data
  let message: String
  if let deliverAt = formData.deliverAt {
    message = """
      Your gift will be delivered to \(formData.toEmail.rawValue) on \
      \(dateFormatter.string(from: deliverAt))."
      """
  } else {
    message = """
      Your gift has been delivered to \(formData.toEmail.rawValue).
      """
  }
  return conn |> redirect(to: .gifts(.index), headersMiddleware: flash(.notice, message))
}
