import ConcurrencyExtras
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
      let index: Int =
        printer.classes.firstIndex(of: style)
        ?? {
          defer { printer.classes.append(style) }
          return printer.classes.count
        }()

      #if DEBUG
        let className = "\(style.property)-\(index)"
      #else
        let className = "c\(index)"
      #endif
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
