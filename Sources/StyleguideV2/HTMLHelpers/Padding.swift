extension HTML {
  public func padding(_ padding: Padding, _ media: MediaQuery? = nil) -> some HTML {
    self
      .inlineStyle("padding-top", padding.top.map { "\($0.rawValue)rem" }, media: media?.rawValue)
      .inlineStyle("padding-left", padding.left.map { "\($0.rawValue)rem" }, media: media?.rawValue)
      .inlineStyle(
        "padding-bottom", padding.bottom.map { "\($0.rawValue)rem" }, media: media?.rawValue
      )
      .inlineStyle(
        "padding-right", padding.right.map { "\($0.rawValue)rem" }, media: media?.rawValue
      )
  }

  public func padding(
    _ top: Spacing? = nil,
    _ left: Spacing? = nil,
    _ bottom: Spacing? = nil,
    _ right: Spacing? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    padding(Padding(top: top, left: left, bottom: bottom, right: right), media)
  }

  @_disfavoredOverload
  public func padding(
    topBottom: Spacing? = nil,
    leftRight: Spacing? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    padding(Padding(topBottom: topBottom, leftRight: leftRight), media)
  }

  public func padding(_ all: Spacing, _ media: MediaQuery? = nil) -> some HTML {
    padding(Padding(all: all), media)
  }
}

public struct Padding {
  public var top: Spacing?
  public var left: Spacing?
  public var bottom: Spacing?
  public var right: Spacing?

  public init(
    top: Spacing? = nil,
    left: Spacing? = nil,
    bottom: Spacing? = nil,
    right: Spacing? = nil
  ) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  public init(
    topBottom: Spacing? = nil,
    leftRight: Spacing? = nil
  ) {
    self.init(top: topBottom, left: leftRight, bottom: topBottom, right: leftRight)
  }

  public init(
    all: Spacing? = nil
  ) {
    self.init(topBottom: all, leftRight: all)
  }
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
