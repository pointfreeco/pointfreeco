import Css
import Prelude

public enum Breakpoint: String {
  case mobile = "m"
  case desktop = "d"

  public static let all: [Breakpoint] = [.mobile, .desktop]

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

  public func querySelfAndBigger(only mediaType: MediaType, rs: () -> Stylesheet) -> Stylesheet {
    return self.minSize.map(minWidth).map { Css.queryOnly(mediaType, [$0], rs: rs) }
      ?? rs()
  }

  public func query(only mediaType: MediaType, rs: () -> Stylesheet) -> Stylesheet {

    let features: [Feature] = [
      self.minSize.map(minWidth),
      self.maxSize.map(maxWidth)
      ]
      |> catOptionals

    return queryOnly(mediaType, features, rs: rs)
  }
}
