import ConcurrencyExtras
import OrderedCollections

extension HTML {
  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: MediaQuery? = nil,
    pseudo: Pseudo? = nil
  ) -> HTMLInlineStyle<Self> {
    HTMLInlineStyle(
      content: self,
      property: property,
      value: value,
      mediaQuery: mediaQuery,
      pseudo: pseudo
    )
  }
}

public struct HTMLInlineStyle<Content: HTML>: HTML {
  let content: Content
  var styles: [(String, String, MediaQuery?, Pseudo?)]

  init(
    content: Content,
    property: String,
    value: String?,
    mediaQuery: MediaQuery?,
    pseudo: Pseudo?
  ) {
    self.content = content
    self.styles = value.map { [(property, $0, mediaQuery, pseudo)] } ?? []
  }

  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: MediaQuery? = nil,
    pseudo: Pseudo? = nil
  ) -> HTMLInlineStyle {
    var copy = self
    if let value {
      copy.styles.append((property, value, mediaQuery, pseudo))
    }
    return copy
  }

  public static func _render(_ html: HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
    let previousClass = printer.attributes["class"]  // TODO: should we optimize this?
    defer {
      Content._render(html.content, into: &printer)
      printer.attributes["class"] = previousClass
    }

    for (property, value, mediaQuery, pseudo) in html.styles {
      let uniqueID = "\(property)\(value)\(mediaQuery?.rawValue ?? "")\(pseudo?.rawValue ?? "")"
      let id = classes.withValue { classes in
        guard let index = classes.firstIndex(of: uniqueID)
        else {
          classes.append(uniqueID)
          return classes.count - 1
        }
        return index
      }

      #if DEBUG
        let className = "\(property)-\(id)"
      #else
        let className = "c\(id)"
      #endif
      let pseudo = "\(className)\(pseudo?.rawValue ?? "")"

      if printer.styles[mediaQuery, default: [:]][pseudo] == nil {
        printer.styles[mediaQuery, default: [:]][pseudo] = "\(property):\(value)"
      }
      printer.attributes["class", default: ""]!.append("\(className) ")
    }
  }
  public var body: Never { fatalError() }
}

private let classes = LockIsolated<OrderedSet<String>>([])

public struct MediaQuery: RawRepresentable, Hashable {
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  public var rawValue: String
}

public struct Pseudo: RawRepresentable {
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
