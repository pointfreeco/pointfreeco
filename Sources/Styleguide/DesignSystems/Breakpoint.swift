import Css
import Prelude

public enum _Breakpoint: String {
  case mobile = "m"
  case desktop = "d"

  public static let all: [_Breakpoint] = [.mobile, .desktop]

  public var minSize: Size? {
    switch self {
    case .mobile:
      return nil
    case .desktop:
      return .px(832)
    }
  }

  public var maxSize: Size? {
    switch self {
    case .mobile:
      return .px(831)
    case .desktop:
      return nil
    }
  }

  public func queryOnly(_ mediaType: MediaType, rs: () -> Stylesheet) -> Stylesheet {
    let features: [Feature] = [
      self.minSize.map(minWidth),
      self.maxSize.map(maxWidth)
    ] |> catOptionals

    return Css.queryOnly(mediaType, features, rs: rs)
  }

  public func querySelfAndBigger(only mediaType: MediaType, rs: () -> Stylesheet) -> Stylesheet {
    return self.minSize.map(minWidth).map { Css.queryOnly(mediaType, [$0], rs: rs) }
      ?? rs()
  }
}

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
