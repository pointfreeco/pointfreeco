extension HTML {
  public func padding(_ all: CSSSize, _ media: MediaQuery? = nil) -> some HTML {
    padding(top: all, left: all, bottom: all, right: all, media)
  }

  public func padding(
    top: CSSSize? = nil,
    left: CSSSize? = nil,
    bottom: CSSSize? = nil,
    right: CSSSize? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    inlineStyle("padding-top", top.map(\.description), media: media?.rawValue)
      .inlineStyle("padding-left", left.map(\.description), media: media?.rawValue)
      .inlineStyle("padding-bottom", bottom.map(\.description), media: media?.rawValue)
      .inlineStyle("padding-right", right.map(\.description), media: media?.rawValue)
  }

  @HTMLBuilder
  public func padding(
    _ all: Spacing,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    let all = CSSSize.rem(all.rawValue)
    padding(top: all, left: all, bottom: all, right: all)
  }

  public func padding(
    top: Spacing? = nil,
    left: Spacing? = nil,
    bottom: Spacing? = nil,
    right: Spacing? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    padding(
      top: top.map { .rem($0.rawValue) },
      left: left.map { .rem($0.rawValue) },
      bottom: bottom.map { .rem($0.rawValue) },
      right: right.map { .rem($0.rawValue) }
    )
  }
}

public struct MediaQuery {
  public var rawValue: String

  public static let desktop = Self(rawValue: "only screen and (min-width: 832px)")
}

public enum Spacing: Double, CaseIterable, ExpressibleByIntegerLiteral {
  case zero = 0
  case extraSmall = 0.5
  case small = 1
  case medium = 2
  case large = 4
  case extraLarge = 8

  public init(integerLiteral value: IntegerLiteralType) {
    self = Self.allCases[value]
  }
}
