import Css
import Prelude

public enum PaddingClass {
  public static func all(_ n: Int) -> CssSelector {
    return .class("p\(n)")
  }

  public static func top(_ n: Int) -> CssSelector {
    return .class("pt\(n)")
  }

  public static func right(_ n: Int) -> CssSelector {
    return .class("pr\(n)")
  }

  public static func bottom(_ n: Int) -> CssSelector {
    return .class("pb\(n)")
  }

  public static func left(_ n: Int) -> CssSelector {
    return .class("pl\(n)")
  }
}

public let spacingStyles =
  paddingStyles
    <> marginStyles
    <> marginAutoStyles

private let spacings: [(Int, Size)] = [(0, 0), (1, .rem(0.5)), (2, .rem(1.0)), (3, .rem(2.0)), (4, .rem(4.0))]

private let paddingStyles: Stylesheet =
  spacings.map {
    PaddingClass.all($0.0) % padding(all: $0.1)
      <> PaddingClass.left($0.0) % padding(left: $0.1)
      <> PaddingClass.top($0.0) % padding(top: $0.1)
      <> PaddingClass.bottom($0.0) % padding(bottom: $0.1)
      <> PaddingClass.right($0.0) % padding(right: $0.1)
    }
    .concat()

public enum MarginClass {
  public static func all(_ n: Int) -> CssSelector {
    return .class("m\(n)")
  }

  public static func top(_ n: Int) -> CssSelector {
    return .class("mt\(n)")
  }

  public static func right(_ n: Int) -> CssSelector {
    return .class("mr\(n)")
  }

  public static func bottom(_ n: Int) -> CssSelector {
    return .class("mb\(n)")
  }

  public static func left(_ n: Int) -> CssSelector {
    return .class("ml\(n)")
  }

  public static let autoLeft = CssSelector.class("ml-auto")
  public static let autoRight = CssSelector.class("mr-auto")
  public static let autoLeftAndRight = CssSelector.class("mx-auto")
}

private let marginStyles: Stylesheet =
  spacings.map {
    MarginClass.all($0.0) % margin(all: $0.1)
      <> MarginClass.left($0.0) % margin(left: $0.1)
      <> MarginClass.top($0.0) % margin(top: $0.1)
      <> MarginClass.bottom($0.0) % margin(bottom: $0.1)
      <> MarginClass.right($0.0) % margin(right: $0.1)
    }
    .concat()

private let marginAutoStyles: Stylesheet =
  MarginClass.autoLeft % margin(left: .auto)
    <> MarginClass.autoRight % margin(right: .auto)
    <> MarginClass.autoLeftAndRight % margin(leftRight: .auto)
