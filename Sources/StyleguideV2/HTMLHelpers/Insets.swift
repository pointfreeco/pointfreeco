extension HTML {
  public func margin(_ margin: Insets, _ media: MediaQuery? = nil) -> some HTML {
    self
      .inlineStyle("margin-top", margin.top.map { "\($0.rawValue)rem" }, media: media)
      .inlineStyle("margin-left", margin.left.map { "\($0.rawValue)rem" }, media: media)
      .inlineStyle("margin-bottom", margin.bottom.map { "\($0.rawValue)rem" }, media: media)
      .inlineStyle("margin-right", margin.right.map { "\($0.rawValue)rem" }, media: media)
  }

  public func margin(
    top: Spacing? = nil,
    left: Spacing? = nil,
    bottom: Spacing? = nil,
    right: Spacing? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    margin(Insets(top: top, left: left, bottom: bottom, right: right), media)
  }

  @_disfavoredOverload
  public func margin(
    topBottom: Spacing? = nil,
    leftRight: Spacing? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    margin(Insets(topBottom: topBottom, leftRight: leftRight), media)
  }

  public func margin(_ all: Spacing, _ media: MediaQuery? = nil) -> some HTML {
    margin(Insets(all: all), media)
  }

  public func padding(_ padding: Insets, _ media: MediaQuery? = nil) -> some HTML {
    self
      .inlineStyle("padding-top", padding.top.map { "\($0.rawValue)rem" }, media: media)
      .inlineStyle("padding-left", padding.left.map { "\($0.rawValue)rem" }, media: media)
      .inlineStyle("padding-bottom", padding.bottom.map { "\($0.rawValue)rem" }, media: media)
      .inlineStyle("padding-right", padding.right.map { "\($0.rawValue)rem" }, media: media)
  }

  public func padding(
    top: Spacing? = nil,
    left: Spacing? = nil,
    bottom: Spacing? = nil,
    right: Spacing? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    padding(Insets(top: top, left: left, bottom: bottom, right: right), media)
  }

  @_disfavoredOverload
  public func padding(
    topBottom: Spacing? = nil,
    leftRight: Spacing? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    padding(Insets(topBottom: topBottom, leftRight: leftRight), media)
  }

  public func padding(_ all: Spacing, _ media: MediaQuery? = nil) -> some HTML {
    padding(Insets(all: all), media)
  }
}

public struct Insets {
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
