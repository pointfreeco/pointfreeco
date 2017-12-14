import Css
import Prelude

extension Class {
  public static let border = (
    circle: CssSelector.class("circle"),
    pill: CssSelector.class("pill"),
    rounded: (
      all: CssSelector.class("rounded"),
      left: CssSelector.class("rounded-left"),
      right: CssSelector.class("rounded-right")
    ),
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

private let cornerRadius = 6.0

private let roundedStyles =
  Class.border.rounded.all % borderRadius(all: .px(cornerRadius))
    <> Class.border.rounded.left % borderRadius(topLeft: .px(cornerRadius), bottomLeft: .px(cornerRadius))
    <> Class.border.rounded.right % borderRadius(topRight: .px(cornerRadius), bottomRight: .px(cornerRadius))
    <> Class.border.circle % borderRadius(all: .pct(50))
    <> Class.border.pill % borderRadius(all: .px(9999))
