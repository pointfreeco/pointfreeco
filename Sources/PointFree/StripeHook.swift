import Either
import Foundation
import HttpPipeline
import Prelude

let stripeSubscriptionWebhookMiddleware: Middleware<StatusLineOpen, ResponseEnded, Stripe.Event<Stripe.Subscription>, Data> =
  validateStripeSignature
    <| updateStripeSubscription

private let tolerance: TimeInterval = 5 * 60

private func validateStripeSignature<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { conn in
      let pairs = conn.request.value(forHTTPHeaderField: "Stripe-Signature").map {
        $0.split(separator: ",")
          .flatMap { pair -> (String, String)? in
            let pair = pair.split(separator: "=", maxSplits: 1).map(String.init)
            return tuple <¢> pair.first <*> (pair.count == 2 ? pair.last : nil)
        }
      }
      let components = pairs
        .map(Dictionary.init)
        .flatMap { tuple3 <¢> $0["v1"] <*> $0["t"].flatMap(Int.init) <*> conn.request.httpBody }

      let signatureValid = components
        .map { signature, timestamp, payload -> Bool in
          Date(timeIntervalSince1970: TimeInterval(timestamp))
            > AppEnvironment.current.date().addingTimeInterval(-tolerance)
            && signature == hexDigest(
              value: "\(timestamp).\(payload)",
              asciiSecret: AppEnvironment.current.envVars.stripe.endpointSecret
          )
        }
        ?? false

      if signatureValid {
        return conn |> middleware
      } else {
        return conn |> writeStatus(.badRequest) >-> end
      }
    }
}

private func updateStripeSubscription(
  _ conn: Conn<StatusLineOpen, Stripe.Event<Stripe.Subscription>>
  )
  -> IO<Conn<ResponseEnded, Data>> {

    let event = conn.data
    let subscription = event.data.object

    return AppEnvironment.current.database.updateStripeSubscription(subscription)
      .run
      .flatMap(
        either(const(conn |> writeStatus(.badRequest) >-> end)) { _ in
          if subscription.status == .pastDue {
            // TODO: Send email
          }

          return conn |> writeStatus(.ok) >-> end
        }
    )
}
