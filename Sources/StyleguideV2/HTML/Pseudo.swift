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
