import Css
import Prelude

extension Class {
  public enum padding {
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

    public static func leftRight(_ n: Int) -> CssSelector {
      return .class("px\(n)")
    }

    public static func topBottom(_ n: Int) -> CssSelector {
      return .class("py\(n)")
    }
  }

  public enum margin {
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
}

public let spacingStyles =
  paddingStyles
    <> marginStyles
    <> marginAutoStyles

private let spacings: [(Int, Size)] = [
  (0, 0),
  (1, .rem(0.5)),
  (2, .rem(1.0)),
  (3, .rem(2.0)),
  (4, .rem(4.0))
]

private func paddings(idx: Int, size: Size) -> Stylesheet {
  return Class.padding.all(idx) % padding(all: size)
    <> Class.padding.left(idx) % padding(left: size)
    <> Class.padding.top(idx) % padding(top: size)
    <> Class.padding.bottom(idx) % padding(bottom: size)
    <> Class.padding.right(idx) % padding(right: size)
    <> Class.padding.leftRight(idx) % padding(leftRight: size)
    <> Class.padding.topBottom(idx) % padding(topBottom: size)
}

private let paddingStyles: Stylesheet =
  spacings
    .map(paddings(idx:size:))
    .concat()

private let marginStyles: Stylesheet =
  spacings.map {
    Class.margin.all($0.0) % margin(all: $0.1)
      <> Class.margin.left($0.0) % margin(left: $0.1)
      <> Class.margin.top($0.0) % margin(top: $0.1)
      <> Class.margin.bottom($0.0) % margin(bottom: $0.1)
      <> Class.margin.right($0.0) % margin(right: $0.1)
    }
    .concat()

private let marginAutoStyles: Stylesheet =
  Class.margin.autoLeft % margin(left: .auto)
    <> Class.margin.autoRight % margin(right: .auto)
    <> Class.margin.autoLeftAndRight % margin(leftRight: .auto)
