import Css
import Prelude

extension Class {
  public static let hide = (
    all: CssSelector.class("hide"),
    xs: CssSelector.class("xs-hide"),
    sm: CssSelector.class("sm-hide"),
    md: CssSelector.class("md-hide"),
    lg: CssSelector.class("lg-hide")
  )
}

public let hideStyles: Stylesheet =
  hideAllStyles
    <> responsiveStyles

private let hideAllStyles =
  Class.hide.all % (
    position(.absolute)
      <> height(.px(1))
      <> width(.px(1))
      <> overflow(.hidden)
      <> clip(rect(top: .px(1), right: .px(1), bottom: .px(1), left: .px(1)))
)

private let responsiveStyles: Stylesheet =
  queryOnly(screen, [maxWidth(Breakpoint.sm.minSize)]) {
    Class.hide.xs % display(.none)
    }
    <>
    queryOnly(screen, [minWidth(Breakpoint.sm.minSize), maxWidth(Breakpoint.md.minSize)]) {
      Class.hide.sm % display(.none)
    }
    <>
    queryOnly(screen, [minWidth(Breakpoint.md.minSize), maxWidth(Breakpoint.lg.minSize)]) {
      Class.hide.md % display(.none)
    }
    <>
    queryOnly(screen, [minWidth(Breakpoint.lg.minSize)]) {
      Class.hide.lg % display(.none)
}

