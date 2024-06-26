extension HTML {
  public func padding(_ all: CSSSize) -> some HTML {
    padding(top: all, left: all, bottom: all, right: all)
  }

  public func padding(
    top: CSSSize? = nil,
    left: CSSSize? = nil,
    bottom: CSSSize? = nil,
    right: CSSSize? = nil
  ) -> some HTML {
    inlineStyle("padding-top", top.map(\.description))
      .inlineStyle("padding-left", left.map(\.description))
      .inlineStyle("padding-bottom", bottom.map(\.description))
      .inlineStyle("padding-right", right.map(\.description))
  }

  @HTMLBuilder
  public func padding(_ all: Spacing) -> some HTML {
    let all = CSSSize.rem(all.rawValue)
    padding(top: all, left: all, bottom: all, right: all)
  }

  public func padding(
    top: Spacing? = nil,
    left: Spacing? = nil,
    bottom: Spacing? = nil,
    right: Spacing? = nil
  ) -> some HTML {
    padding(
      top: top.map { .rem($0.rawValue) },
      left: left.map { .rem($0.rawValue) },
      bottom: bottom.map { .rem($0.rawValue) },
      right: right.map { .rem($0.rawValue) }
    )
  }
}

public enum Spacing: Double {
  case zero = 0
  case extraSmall = 0.5
  case small = 1
  case medium = 2
  case large = 4
  case extraLarge = 8
}
