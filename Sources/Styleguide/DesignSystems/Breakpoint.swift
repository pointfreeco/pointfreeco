import Css

public enum Breakpoint: String {
  case lg
  case md
  case sm
  case xs

  public var minSize: Size {
    switch self {
    case .xs: return .em(24)
    case .sm: return .em(40)
    case .md: return .em(52)
    case .lg: return .em(64)
    }
  }

  public static let all: [Breakpoint] = [.lg, .md, .sm, .xs]
}
