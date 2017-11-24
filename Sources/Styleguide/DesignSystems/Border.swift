import Css
import Prelude

extension Class {
  public static let border = (
    circle: CssSelector.class("circle"),
    pill: CssSelector.class("pill"),
    rounded: CssSelector.class("rounded"),
    all: CssSelector.class("border"),
    top: CssSelector.class("border-top"),
    right: CssSelector.class("border-right"),
    bottom: CssSelector.class("border-bottom"),
    left: CssSelector.class("border-left"),
    none: CssSelector.class("border-none")
  )
}

public let borderStyles: Stylesheet =
  Class.border.all % (
    borderStyle(all: .solid)
      <> borderWidth(all: .px(1))
    )
    <> Class.border.top % (
      borderStyle(top: .solid)
        <> borderWidth(top: .px(1))
    )
    <> Class.border.right % (
      borderStyle(right: .solid)
        <> borderWidth(right: .px(1))
    )
    <> Class.border.bottom % (
      borderStyle(bottom: .solid)
        <> borderWidth(bottom: .px(1))
    )
    <> Class.border.left % (
      borderStyle(left: .solid)
        <> borderWidth(left: .px(1))
    )
    <> Class.border.none % (
      borderStyle(all: .none)
        <> borderWidth(all: 0)
    )
    <> roundedStyles

private let roundedStyles =
  Class.border.rounded % borderRadius(all: .px(3))
    <> Class.border.circle % borderRadius(all: .pct(50))
    <> Class.border.pill % borderRadius(all: .px(9999))
