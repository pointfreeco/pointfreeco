@testable import Css
import Prelude

public enum HideClass {
  public static let hide = CssSelector.class("hide")
  public static let xsHide = CssSelector.class("xs-hide")
  public static let smHide = CssSelector.class("sm-hide")
  public static let mdHide = CssSelector.class("md-hide")
  public static let lgHide = CssSelector.class("lg-hide")
}

public let hideStyles: Stylesheet =
  HideClass.hide % (
    position(.absolute)
      <> height(.px(1))
      <> width(.px(1))
      <> overflow(.hidden)
      <> clip(rect(top: .px(1), right: .px(1), bottom: .px(1), left: .px(1)))
    )
    <> responsiveStyles

private let responsiveStyles: Stylesheet =
  queryOnly(screen, [maxWidth(Breakpoints.sm)]) {
    HideClass.xsHide % display(.none)
    }
    <>
    queryOnly(screen, [minWidth(Breakpoints.sm), maxWidth(Breakpoints.md)]) {
      HideClass.smHide % display(.none)
    }
    <>
    queryOnly(screen, [minWidth(Breakpoints.md), maxWidth(Breakpoints.lg)]) {
      HideClass.mdHide % display(.none)
    }
    <>
    queryOnly(screen, [minWidth(Breakpoints.lg)]) {
      HideClass.lgHide % display(.none)
}

public enum Breakpoints {
  public static let sm: Size = .em(40)
  public static let md: Size = .em(52)
  public static let lg: Size = .em(64)
}




// TODO: move to swift-web/Display
public struct Clip: Val, Other, Auto, Inherit {
  let clip: Value

  public func value() -> Value {
    return self.clip
  }

  public static func other(_ other: Value) -> Clip {
    return .init(clip: other)
  }

  public static let auto = Clip(clip: "auto")
  public static let inherit = Clip(clip: "inherit")
}

public func clip(_ clip: Clip) -> Stylesheet {
  return key("clip")(clip)
}

public func rect(top: Size, right: Size, bottom: Size, left: Size) -> Clip {
  return Clip(
    clip: Value(
      [
        "rect(",
        top.value().unValue,
        right.value().unValue,
        bottom.value().unValue,
        left.value().unValue,
        ")"
        ]
        .concat()
    )
  )
}
