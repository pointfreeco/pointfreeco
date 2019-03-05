import ApplicativeRouter
import HttpPipeline
import Models
import Prelude
import Tagged
import UrlFormEncoding

func payload<A, B>(
  _ iso1: PartialIso<String, A>,
  _ iso2: PartialIso<String, B>,
  separator: String = "--POINT-FREE-BOUNDARY--"
  )
  -> PartialIso<String, (A, B)> {

    return PartialIso<String, (A, B)>(
      apply: { payload in
        let parts = payload.components(separatedBy: separator)
        guard
          let first = parts.first.flatMap(iso1.apply),
          let second = parts.last.flatMap(iso2.apply) else { return nil }
        return (first, second)
    },
      unapply: { first, second in
        guard
          let first = iso1.unapply(first),
          let second = iso2.unapply(second)
          else { return nil }
        return "\(first)\(separator)\(second)"
    })
}

extension PartialIso where A == String, B == String {
  static func decrypted(withSecret secret: String) -> PartialIso<String, String> {
    return PartialIso(
      apply: { HttpPipeline.decrypted(text: $0, secret: secret) },
      unapply: { encrypted(text: $0, secret: secret) }
    )
  }
}

extension PartialIso where B: TaggedType, A == B.RawValue {
  static var tagged: PartialIso<B.RawValue, B> {
    return PartialIso(
      apply: B.init(rawValue:),
      unapply: ^\.rawValue
    )
  }
}

let isTest: Router<Bool?> =
  formField("live", .string).map(isPresent >>> negate >>> Optional.iso.some)
    <|> formField("test", .string).map(isPresent >>> Optional.iso.some)

let isPresent = PartialIso<String, Bool>(apply: const(true), unapply: { $0 ? "" : nil })
let negate = PartialIso<Bool, Bool>(apply: (!), unapply: (!))

let formDecoder: UrlFormDecoder = {
  let decoder = UrlFormDecoder()
  decoder.parsingStrategy = .bracketsWithIndices
  return decoder
}()

extension PartialIso where A == (String?, Int?), B == Pricing {
  static var pricing: PartialIso {
    return PartialIso(
      apply: { plan, quantity in
        let billing = plan.flatMap(Pricing.Billing.init(rawValue:)) ?? .monthly
        let quantity = clamp(1..<Pricing.validTeamQuantities.upperBound) <| (quantity ?? 1)
        return Pricing(billing: billing, quantity: quantity)
    }, unapply: { pricing -> (String?, Int?) in
      (pricing.billing.rawValue, pricing.quantity)
    })
  }
}

func slug(for string: String) -> String {
  return string
    .lowercased()
    .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "\\A-|-\\z", with: "", options: .regularExpression)
}

extension PartialIso where A == MailgunForwardPayload, B == MailgunForwardPayload {
  static func signatureVerification(apiKey: String) -> PartialIso {
    return PartialIso(
      apply: { verify(payload: $0, apiKey: apiKey) ? .some($0) : nil },
      unapply: { $0 }
    )
  }
}

private func verify(payload: MailgunForwardPayload, apiKey: String) -> Bool {
  let digest = hexDigest(
    value: "\(payload.timestamp)\(payload.token)",
    asciiSecret: apiKey
  )
  return payload.signature == digest

}

extension PartialIso {
  /// Promotes a partial iso to one that deals with tagged values, e.g.
  ///
  ///    PartialIso<String, User.Id>.tagged(.string)
  public static func tagged<T, C>(
    _ iso: PartialIso<A, C>
    ) -> PartialIso<A, B>
    where B == Tagged<T, C> {

      return iso >>> .tagged
  }
}
