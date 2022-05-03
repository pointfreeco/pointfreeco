import Either
import Foundation
import HttpPipeline
import Prelude

func validateStripeSignature<A>(_ middleware: @escaping M<A>) -> M<A> {
  return { conn in
    let pairs =
      conn.request.value(forHTTPHeaderField: "Stripe-Signature")
      .map(keysWithAllValues(separator: ","))
      ?? []

    let params = Dictionary(pairs, uniquingKeysWith: +)

    guard
      let timestamp = params["t"]?.first.flatMap(Int.init).map(TimeInterval.init),
      shouldTolerate(timestamp),
      let signatures = params["v1"],
      let payload = conn.request.httpBody.map({ String(decoding: $0, as: UTF8.self) }),
      signatures.contains(where: isSignatureValid(timestamp: timestamp, payload: payload))
    else {
      return conn
        |> stripeHookFailure(
          subject: "[PointFree Error] Stripe Hook Failed!",
          body: "Couldn't verify signature."
        )
    }

    return conn |> middleware
  }
}

func stripeHookFailure<A>(
  subject: String = "[PointFree Error] Stripe Hook Failed!",
  body: String
)
  -> (Conn<StatusLineOpen, A>)
  -> IO<Conn<ResponseEnded, Data>>
{

  return { conn in
    IO<Void> {
      var requestDump = body + "\n\n"
      print("Current timestamp: \(Current.date().timeIntervalSince1970)", to: &requestDump)
      print(
        "\n\(conn.request.httpMethod ?? "?METHOD?") \(conn.request.url?.absoluteString ?? "?URL?")",
        to: &requestDump
      )
      print("\nHeaders:", to: &requestDump)
      dump(conn.request.allHTTPHeaderFields, to: &requestDump)
      print("\nBody:", to: &requestDump)
      print(String(decoding: conn.request.httpBody ?? .init(), as: UTF8.self), to: &requestDump)

      parallel(
        sendEmail(
          to: adminEmails,
          subject: subject,
          content: inj1(requestDump)
        ).run
      ).run { _ in }
    }
    .flatMap {
      conn
        |> writeStatus(.badRequest)
        >=> respond(text: body)
    }
  }
}

public func generateStripeSignature(
  timestamp: Int,
  payload: String
) -> String? {
  hexDigest(
    value: "\(timestamp).\(payload)",
    asciiSecret: Current.envVars.stripe.endpointSecret.rawValue
  )
}

private func isSignatureValid(timestamp: TimeInterval, payload: String) -> (String) -> Bool {
  return { signature in
    guard let digest = generateStripeSignature(timestamp: Int(timestamp), payload: payload)
    else { return false }

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
    > Current.date().addingTimeInterval(-tolerance)
}

private func keysWithAllValues(separator: Character) -> (String) -> [(String, [String])] {
  return { string in
    string.split(separator: separator)
      .compactMap { pair -> (String, [String])? in
        let pair = pair.split(separator: "=", maxSplits: 1).map(String.init)
        return tuple <¢> pair.first <*> (pair.count == 2 ? [pair[1]] : nil)
      }
  }
}
