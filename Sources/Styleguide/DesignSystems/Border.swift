import Css
import Prelude

let borderCss = FunctionM<Double, Stylesheet> { cornerRadius in

  let roundedCss = Class.border.rounded.all % borderRadius(all: .px(cornerRadius))
    <> Class.border.rounded.left % borderRadius(topLeft: .px(cornerRadius), bottomLeft: .px(cornerRadius))
    <> Class.border.rounded.right % borderRadius(topRight: .px(cornerRadius), bottomRight: .px(cornerRadius))
    <> Class.border.circle % borderRadius(all: .pct(50))
    <> Class.border.pill % borderRadius(all: .px(9999))

  return Class.border.all % (borderStyle(all: .solid) <> borderWidth(all: .px(1)))
    <> Class.border.top % (borderStyle(top: .solid) <> borderWidth(top: .px(1)))
    <> Class.border.right % (borderStyle(right: .solid) <> borderWidth(right: .px(1)))
    <> Class.border.bottom % (borderStyle(bottom: .solid) <> borderWidth(bottom: .px(1)))
    <> Class.border.left % (borderStyle(left: .solid) <> borderWidth(left: .px(1)))
    <> Class.border.none % (borderStyle(all: .none) <> borderWidth(all: 0))
    <> roundedCss
}

extension Class {
  public enum border {
    public static let circle = CssSelector.class("circle")
    public static let pill = CssSelector.class("pill")
    public enum rounded {
      public static let all = CssSelector.class("rounded")
      public static let left = CssSelector.class("rounded-left")
      public static let right = CssSelector.class("rounded-right")
    }
    public static let all = CssSelector.class("border")
    public static let top = CssSelector.class("border-top")
    public static let right = CssSelector.class("border-right")
    public static let bottom = CssSelector.class("border-bottom")
    public static let left = CssSelector.class("border-left")
    public static let none = CssSelector.class("border-none")
  }
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
