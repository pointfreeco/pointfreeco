import Foundation
import HttpPipeline
import Models
import Prelude
import Stripe

let stripePaymentIntentsWebhookMiddleware
  : (Conn<StatusLineOpen, Event<PaymentIntent>>) -> IO<Conn<ResponseEnded, Data>>
  = validateStripeSignature
    <<< validateEvent
    <| handlePaymentIntent

private func validateEvent(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, PaymentIntent, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Event<PaymentIntent>, Data> {

  return { conn in
    let event = conn.data
    switch event.type {
    case .paymentIntentPaymentFailed:
      // TODO: Email gift giver?
      return conn |> writeStatus(.ok) >=> respond(text: "OK")

    case .paymentIntentSucceeded:
      return conn.map(const(event.data.object)) |> middleware

    default:
      return conn |> stripeHookFailure(
        subject: "[PointFree Error] Stripe Hook Failed!",
        body: "Payment intents hook received unhandled event \(event.type)"
      )
    }
  }
}

private func fetchGift(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, (PaymentIntent, Gift), Data>
) -> Middleware<StatusLineOpen, ResponseEnded, PaymentIntent, Data> {

  return { conn in
    let paymentIntent = conn.data
    return Current.database.fetchGiftByStripePaymentIntentId(paymentIntent.id)
      .run
      .map { errorOrGift in
        switch errorOrGift {
        case .left:
          return conn |> writeStatus(.ok) >=> respond(text: "OK")

        case let .right(gift):
          return conn.map(const(gift)) |> middleware
        }
      }
  }
}

private func handlePaymentIntent(
  conn: Conn<StatusLineOpen, Gift>
) -> IO<Conn<ResponseEnded, Data>> {
  let (paymentIntent, gift) = conn.data

  return Current.database.fetchGiftByStripePaymentIntentId(paymentIntent.id)
    .flatMap { gift in
      Current.stripe.createCoupon(
        .once,
        1,
        "\(gift.monthsFree) months free",
        .amountOff(paymentIntent.amount)
      )
      .flatMap { coupon in Current.database.updateGift(gift.id, coupon.id) }
    }
    .run
    .flatMap {
      switch $0 {
      case let .left(error):
        return conn |> stripeHookFailure(
          subject: "[PointFree Error] Stripe Hook Failed!",
          body: "Unable to create coupon for gift \(gift.id): \(error)"
        )

      case let .right(gift):
        return conn |> writeStatus(.ok) >=> respond(text: "OK")
      }
    }
}
