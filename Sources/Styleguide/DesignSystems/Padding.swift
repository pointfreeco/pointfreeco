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

private let paddingStyles: Stylesheet =
  PaddingClass.all(0) % padding(all: 0)
    <> PaddingClass.all(1) % padding(all: .rem(1))
    <> PaddingClass.all(2) % padding(all: .rem(2))
    <> PaddingClass.all(3) % padding(all: .rem(3))
    <> PaddingClass.all(4) % padding(all: .rem(4))
    <> PaddingClass.all(5) % padding(all: .rem(5))

    <> PaddingClass.top(0) % padding(top: 0)
    <> PaddingClass.top(1) % padding(top: .rem(1))
    <> PaddingClass.top(2) % padding(top: .rem(2))
    <> PaddingClass.top(3) % padding(top: .rem(3))
    <> PaddingClass.top(4) % padding(top: .rem(4))
    <> PaddingClass.top(5) % padding(top: .rem(5))

    <> PaddingClass.bottom(0) % padding(bottom: 0)
    <> PaddingClass.bottom(1) % padding(bottom: .rem(1))
    <> PaddingClass.bottom(2) % padding(bottom: .rem(2))
    <> PaddingClass.bottom(3) % padding(bottom: .rem(3))
    <> PaddingClass.bottom(4) % padding(bottom: .rem(4))
    <> PaddingClass.bottom(5) % padding(bottom: .rem(5))

    <> PaddingClass.left(0) % padding(left: 0)
    <> PaddingClass.left(1) % padding(left: .rem(1))
    <> PaddingClass.left(2) % padding(left: .rem(2))
    <> PaddingClass.left(3) % padding(left: .rem(3))
    <> PaddingClass.left(4) % padding(left: .rem(4))
    <> PaddingClass.left(5) % padding(left: .rem(5))

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

private let marginStyles =
  MarginClass.all(0) % margin(all: 0)
    <> MarginClass.all(1) % margin(all: .rem(1))
    <> MarginClass.all(2) % margin(all: .rem(2))
    <> MarginClass.all(3) % margin(all: .rem(3))
    <> MarginClass.all(4) % margin(all: .rem(4))
    <> MarginClass.all(5) % margin(all: .rem(5))

    <> MarginClass.top(0) % margin(top: 0)
    <> MarginClass.top(1) % margin(top: .rem(1))
    <> MarginClass.top(2) % margin(top: .rem(2))
    <> MarginClass.top(3) % margin(top: .rem(3))
    <> MarginClass.top(4) % margin(top: .rem(4))
    <> MarginClass.top(5) % margin(top: .rem(5))

    <> MarginClass.bottom(0) % margin(bottom: 0)
    <> MarginClass.bottom(1) % margin(bottom: .rem(1))
    <> MarginClass.bottom(2) % margin(bottom: .rem(2))
    <> MarginClass.bottom(3) % margin(bottom: .rem(3))
    <> MarginClass.bottom(4) % margin(bottom: .rem(4))
    <> MarginClass.bottom(5) % margin(bottom: .rem(5))

    <> MarginClass.left(0) % margin(left: 0)
    <> MarginClass.left(1) % margin(left: .rem(1))
    <> MarginClass.left(2) % margin(left: .rem(2))
    <> MarginClass.left(3) % margin(left: .rem(3))
    <> MarginClass.left(4) % margin(left: .rem(4))
    <> MarginClass.left(5) % margin(left: .rem(5))

    <> MarginClass.autoLeft % margin(left: .auto)
    <> MarginClass.autoRight % margin(right: .auto)
    <> MarginClass.autoLeftAndRight % margin(leftRight: .auto)
