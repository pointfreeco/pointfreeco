import Either
import Foundation
import HttpPipeline
import Prelude

let stripeSubscriptionWebhookMiddleware: Middleware<StatusLineOpen, ResponseEnded, Stripe.Event<Stripe.Subscription>, Data> =
  validateStripeSignature
    <| updateStripeSubscription

private func validateStripeSignature<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { conn in
      let pairs = conn.request.value(forHTTPHeaderField: "Stripe-Signature")
        .map(keysWithAllValues(separator: ","))
        ?? []

      let params = Dictionary(pairs, uniquingKeysWith: +)

      guard
        let timestamp = params["t"].flatMap(^\.first >-> Int.init).map(TimeInterval.init),
        shouldTolerate(timestamp),
        let signatures = params["v1"],
        let payload = conn.request.httpBody.map({ String(decoding: $0, as: UTF8.self) }),
        signatures.contains(where: isSignatureValid(timestamp: timestamp, payload: payload))
        else { return conn |> writeStatus(.badRequest) >-> end }

      return conn |> middleware
    }
}

private func isSignatureValid(timestamp: TimeInterval, payload: String) -> (String) -> Bool {
  return { signature in
    let secret = AppEnvironment.current.envVars.stripe.endpointSecret
    guard let digest = hexDigest(value: "\(timestamp).\(payload)", asciiSecret: secret) else { return false }

    let constantTimeSignature =
      signature.count == digest.count
        ? signature
        : String(repeating: " ", count: digest.count)

    // NB: constant-time equality check
    return zip(constantTimeSignature.utf8, digest.utf8).reduce(true) { $0 && $1.0 == $1.1 }
  }
}

private func shouldTolerate(_ timestamp: TimeInterval, tolerance: TimeInterval = 5 * 60) -> Bool {
  return Date(timeIntervalSince1970: timestamp)
    > AppEnvironment.current.date().addingTimeInterval(-tolerance)
}

private func keysWithAllValues(separator: Character) -> (String) -> [(String, [String])] {
  return { string in
    string.split(separator: ",")
      .flatMap { pair -> (String, [String])? in
        let pair = pair.split(separator: "=", maxSplits: 1).map(String.init)
        return tuple <¢> pair.first <*> (pair.count == 2 ? [pair[1]] : nil)
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
