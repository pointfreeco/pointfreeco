import Dependencies
import Foundation
import HttpPipeline
import Models
import Stripe

func stripePaymentIntentsWebhookMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  event: Event<PaymentIntent>
) async -> Conn<ResponseEnded, Data> {
  if let failure = validateStripeSignature(conn) { return failure }

  switch event.type {
  case .paymentIntentPaymentFailed:
    // TODO: Email gift giver?
    return conn.writeStatus(.ok).respond(text: "OK")

  case .paymentIntentSucceeded:
    return await fetchGift(conn, paymentIntent: event.data.object)

  default:
    return stripeHookFailure(
      conn,
      subject: "[PointFree Error] Stripe Hook Failed!",
      body: "Payment intents hook received unhandled event \(event.type)"
    )
  }
}

private func fetchGift(
  _ conn: Conn<StatusLineOpen, Void>,
  paymentIntent: PaymentIntent
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  guard let gift = try? await database.fetchGift(paymentIntentID: paymentIntent.id)
  else {
    return conn.writeStatus(.ok).respond(text: "OK")
  }
  return await handlePaymentIntent(conn, paymentIntent: paymentIntent, gift: gift)
}

private func handlePaymentIntent(
  _ conn: Conn<StatusLineOpen, Void>,
  paymentIntent: PaymentIntent,
  gift: Gift
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database

  guard paymentIntent.status == .succeeded
  else { return conn.writeStatus(.ok).respond(text: "OK") }

  do {
    let deliverNow = gift.deliverAt == nil
    if deliverNow {
      _ = try await sendGiftEmail(for: gift)
    }
    _ = try await database.updateGiftStatus(gift.id, paymentIntent.status, deliverNow)
    return conn.writeStatus(.ok).respond(text: "OK")
  } catch {
    return stripeHookFailure(
      conn,
      subject: "[PointFree Error] Stripe Hook Failed!",
      body: "Failed to deliver gift \(gift.id): \(error)"
    )
  }
}
