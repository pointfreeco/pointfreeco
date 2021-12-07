import ApplicativeRouter
import Prelude
import Tagged
import UrlFormEncoding

public protocol TaggedType {
  associatedtype Tag
  associatedtype RawValue

  var rawValue: RawValue { get }
  init(rawValue: RawValue)
}

extension Tagged: TaggedType {}

extension PartialIso where B: TaggedType, A == B.RawValue {
  public static var tagged: PartialIso<B.RawValue, B> {
    return PartialIso(
      apply: B.init(rawValue:),
      unapply: { $0.rawValue }
    )
  }
}

public func payload<A, B>(
  _ iso1: PartialIso<String, A>,
  _ iso2: PartialIso<String, B>,
  separator: String = "--POINT-FREE-BOUNDARY--"
) -> PartialIso<String, (A, B)> {
  PartialIso<String, (A, B)>(
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
    }
  )
}

let formDecoder: UrlFormDecoder = {
  let decoder = UrlFormDecoder()
  decoder.parsingStrategy = .bracketsWithIndices
  return decoder
}()

func slug(for string: String) -> String {
  string
    .lowercased()
    .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "\\A-|-\\z", with: "", options: .regularExpression)
}

extension PartialIso {
  public static func tagged<T, C>(
    _ iso: PartialIso<A, C>
  ) -> PartialIso<A, B>
  where B == Tagged<T, C> {
    iso >>> .tagged
  }
}
