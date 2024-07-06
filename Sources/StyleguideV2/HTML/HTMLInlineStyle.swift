import ConcurrencyExtras
import Darwin
import Dependencies
import OrderedCollections

extension HTML {
  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: MediaQuery? = nil,
    pre: String? = nil,
    pseudo: Pseudo? = nil
  ) -> HTMLInlineStyle<Self> {
    HTMLInlineStyle(
      content: self,
      property: property,
      value: value,
      mediaQuery: mediaQuery,
      pre: pre,
      pseudo: pseudo
    )
  }
}

public struct HTMLInlineStyle<Content: HTML>: HTML {
  private let content: Content
  private var styles: [Style]

  @Dependency(ClassNameGenerator.self) fileprivate var classNameGenerator

  init(
    content: Content,
    property: String,
    value: String?,
    mediaQuery: MediaQuery?,
    pre: String? = nil,
    pseudo: Pseudo?
  ) {
    self.content = content
    self.styles =
      value.map {
        [
          Style(
            property: property,
            value: $0,
            media: mediaQuery,
            preSelector: pre,
            pseudo: pseudo
          )
        ]
      }
      ?? []
  }

  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: MediaQuery? = nil,
    pre: String? = nil,
    pseudo: Pseudo? = nil
  ) -> HTMLInlineStyle {
    var copy = self
    if let value {
      copy.styles.append(
        Style(
          property: property,
          value: value,
          media: mediaQuery,
          preSelector: pre,
          pseudo: pseudo
        )
      )
    }
    return copy
  }

  public static func _render(_ html: HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
    let previousClass = printer.attributes["class"]  // TODO: should we optimize this?
    defer {
      Content._render(html.content, into: &printer)
      printer.attributes["class"] = previousClass
    }

    for style in html.styles {
      let className = html.classNameGenerator.generate(style)
      let selector = """
        \(style.preSelector.map { "\($0) " } ?? "").\(className)\(style.pseudo?.rawValue ?? "")
        """

      if printer.styles[style.media, default: [:]][selector] == nil {
        printer.styles[style.media, default: [:]][selector] = "\(style.property):\(style.value)"
      }
      printer
        .attributes["class", default: ""]
        .append(printer.attributes.keys.contains("class") ? " \(className)" : className)
    }
  }
  public var body: Never { fatalError() }
}

private struct ClassNameGenerator: DependencyKey {
  var generate: @Sendable (Style) -> String

  static var liveValue: ClassNameGenerator {
    let seenStyles = LockIsolated<OrderedSet<Style>>([])
    return Self { style in
      seenStyles.withValue { seenStyles in
        let index =
          seenStyles.firstIndex(of: style)
          ?? {
            seenStyles.append(style)
            return seenStyles.count
          }()
        #if DEBUG
        return "\(style.property)-\(index)"
        #else
        return "c\(index)"
        #endif
      }
    }
  }

  static var testValue: ClassNameGenerator {
    Self { style in
      let hash = encode(
        UInt64(
          murmurHash(
            style.value
              + (style.media?.rawValue ?? "")
              + (style.preSelector ?? "")
              + (style.pseudo?.rawValue ?? "")
          )
        )
      )
      return "\(style.property)-\(hash)"
    }
  }
}

private struct Style: Hashable {
  let property: String
  let value: String
  let media: MediaQuery?
  let preSelector: String?
  let pseudo: Pseudo?
}

public struct MediaQuery: RawRepresentable, Hashable {
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  public var rawValue: String
}

public struct Pseudo: RawRepresentable, Hashable {
  public var rawValue: String
  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public static let active = Self(rawValue: ":active")
  public static let checked = Self(rawValue: ":checked")
  public static let disabled = Self(rawValue: ":disabled")
  public static let empty = Self(rawValue: ":empty")
  public static let enabled = Self(rawValue: ":enabled")
  public static let firstChild = Self(rawValue: ":first-child")
  public static let firstOfType = Self(rawValue: ":first-of-type")
  public static let focus = Self(rawValue: ":focus")
  public static let hover = Self(rawValue: ":hover")
  public static let inRange = Self(rawValue: ":in-range")
  public static let invalid = Self(rawValue: ":invalid")
  public static let lang = Self(rawValue: ":lang")
  public static let lastChild = Self(rawValue: ":last-child")
  public static let lastOfType = Self(rawValue: ":last-of-type")
  public static let link = Self(rawValue: ":link")
  public static func nthChild(_ n: String) -> Self { Self(rawValue: ":nth-child(\(n))") }
  public static func nthLastChild(_ n: String) -> Self { Self(rawValue: ":nth-last-child(\(n))") }
  public static func nthLastOfType(_ n: String) -> Self {
    Self(rawValue: ":nth-last-of-type(\(n))")
  }
  public static func nthOfType(_ n: String) -> Self { Self(rawValue: ":nth-of-type(\(n))") }
  public static let onlyChild = Self(rawValue: ":only-child")
  public static let onlyOfType = Self(rawValue: ":only-of-type")
  public static let optional = Self(rawValue: ":optional")
  public static let outOfRange = Self(rawValue: ":out-of-range")
  public static let readOnly = Self(rawValue: ":read-only")
  public static let readWrite = Self(rawValue: ":read-write")
  public static let required = Self(rawValue: ":required")
  public static let root = Self(rawValue: ":root")
  public static let target = Self(rawValue: ":target")
  public static let valid = Self(rawValue: ":valid")
  public static let visited = Self(rawValue: ":visited")
  public static func not(_ other: Self) -> Self { Self(rawValue: ":not(\(other.rawValue))") }
}

private func encode(_ value: UInt64) -> String {
  guard value > 0
  else { return "" }
  var number = value
  var encoded = ""
  encoded.reserveCapacity(Int(log(Double(number)) / log(64)) + 1)
  while number > 0 {
    let index = Int(number % baseCount)
    number /= baseCount
    encoded.append(baseChars[index])
  }

  return encoded
}
private let baseChars = Array("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
private let baseCount = UInt64(baseChars.count)
private func murmurHash(_ string: String) -> UInt32 {
  let data = [UInt8](string.utf8)
  let length = data.count
  let c1: UInt32 = 0xcc9e_2d51
  let c2: UInt32 = 0x1b87_3593
  let r1: UInt32 = 15
  let r2: UInt32 = 13
  let m: UInt32 = 5
  let n: UInt32 = 0xe654_6b64

  var hash: UInt32 = 0

  let chunkSize = MemoryLayout<UInt32>.size
  let chunks = length / chunkSize

  for i in 0..<chunks {
    var k: UInt32 = 0
    let offset = i * chunkSize

    for j in 0..<chunkSize {
      k |= UInt32(data[offset + j]) << (j * 8)
    }

    k &*= c1
    k = (k << r1) | (k >> (32 - r1))
    k &*= c2

    hash ^= k
    hash = (hash << r2) | (hash >> (32 - r2))
    hash = hash &* m &+ n
  }

  var k1: UInt32 = 0
  let tailStart = chunks * chunkSize

  switch length & 3 {
  case 3:
    k1 ^= UInt32(data[tailStart + 2]) << 16
    fallthrough
  case 2:
    k1 ^= UInt32(data[tailStart + 1]) << 8
    fallthrough
  case 1:
    k1 ^= UInt32(data[tailStart])
    k1 &*= c1
    k1 = (k1 << r1) | (k1 >> (32 - r1))
    k1 &*= c2
    hash ^= k1
  default:
    break
  }

  hash ^= UInt32(length)
  hash ^= (hash >> 16)
  hash &*= 0x85eb_ca6b
  hash ^= (hash >> 13)
  hash &*= 0xc2b2_ae35
  hash ^= (hash >> 16)

  return hash
}
