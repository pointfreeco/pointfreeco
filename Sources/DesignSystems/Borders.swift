import Css
import Prelude

let borderCss = FunctionM<Double, Stylesheet> { cornerRadius in

  let roundedCss = Dls.border.rounded.all % borderRadius(all: .px(cornerRadius))
    <> Dls.border.rounded.left % borderRadius(topLeft: .px(cornerRadius), bottomLeft: .px(cornerRadius))
    <> Dls.border.rounded.right % borderRadius(topRight: .px(cornerRadius), bottomRight: .px(cornerRadius))
    <> Dls.border.circle % borderRadius(all: .pct(50))
    <> Dls.border.pill % borderRadius(all: .px(9999))

  return Dls.border.all % (borderStyle(all: .solid) <> borderWidth(all: .px(1)))
    <> Dls.border.top % (borderStyle(top: .solid) <> borderWidth(top: .px(1)))
    <> Dls.border.right % (borderStyle(right: .solid) <> borderWidth(right: .px(1)))
    <> Dls.border.bottom % (borderStyle(bottom: .solid) <> borderWidth(bottom: .px(1)))
    <> Dls.border.left % (borderStyle(left: .solid) <> borderWidth(left: .px(1)))
    <> Dls.border.none % (borderStyle(all: .none) <> borderWidth(all: 0))
    <> roundedCss
}

extension Dls {
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

