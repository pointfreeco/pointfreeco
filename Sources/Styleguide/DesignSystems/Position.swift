import Css
import Prelude

extension Class {
  public enum position {
    public static let top0 = CssSelector.class("top-0")
    public static let right0 = CssSelector.class("right-0")
    public static let bottom0 = CssSelector.class("bottom-0")
    public static let left0 = CssSelector.class("left-0")

    public static let `static` = CssSelector.class("static")
    public static let relative = CssSelector.class("relative")
    public static let absolute = CssSelector.class("absolute")
    public static let fixed = CssSelector.class("fixed")
    public static let sticky = CssSelector.class("sticky")

    public static func sticky(breakpoint: Breakpoint) -> CssSelector {
      return CssSelector.class("sticky-\(breakpoint)")
    }
  }
}

public let positionStyles: Stylesheet =
  Class.position.static % position(.static)
    <> Class.position.relative % position(.relative)
    <> Class.position.absolute % position(.absolute)
    <> Class.position.fixed % position(.fixed)
    <> Class.position.sticky % stickyPosition
    <> responsiveStyles
    <> sideStyles

private let responsiveStyles: Stylesheet = Breakpoint.all
  .map { breakpoint in
    queryOnly(screen, [minWidth(breakpoint.minSize)]) {
      Class.position.sticky(breakpoint: breakpoint) % stickyPosition
    }
  }.concat()

private let stickyPosition =
  position(.sticky)
    <> position("-webkit-sticky")

private let sideStyles: Stylesheet =
  Class.position.top0 % top(0)
    <> Class.position.right0 % right(0)
    <> Class.position.bottom0 % bottom(0)
    <> Class.position.left0 % left(0)
