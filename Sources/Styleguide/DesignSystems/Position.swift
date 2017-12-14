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

    public static func sticky(_ breakpoint: Breakpoint) -> CssSelector {
      return CssSelector.class("sticky-\(breakpoint.rawValue)")
    }

    public static let z1 = CssSelector.class("z1")
    public static let z2 = CssSelector.class("z2")
    public static let z3 = CssSelector.class("z3")
    public static let z4 = CssSelector.class("z4")

    public static let farFarAway = CssSelector.class("far-far-away")
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
    <> zIndexStyles
    <> Class.position.farFarAway % (position(.absolute) <> top(.px(-9999)) <> left(.px(-9999)))

private let responsiveStyles: Stylesheet = Breakpoint.all
  .map { breakpoint in
    breakpoint.querySelfAndBigger(only: screen) {
      Class.position.sticky(breakpoint) % stickyPosition
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

private let zIndexStyles =
  Class.position.z1 % zIndex(1)
    <> Class.position.z2 % zIndex(2)
    <> Class.position.z3 % zIndex(3)
    <> Class.position.z4 % zIndex(4)
