@testable import Css
import Prelude

extension Class {
  public enum hide {
    public static let all = CssSelector.class("hide")
    public static let xs = CssSelector.class("xs-hide")
    public static let sm = CssSelector.class("sm-hide")
    public static let md = CssSelector.class("md-hide")
    public static let lg = CssSelector.class("lg-hide")
  }
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
