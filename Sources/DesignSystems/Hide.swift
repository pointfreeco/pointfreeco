import Css

extension Dls {
  
}

//
//extension Class {
//
//  public static let hide = CssSelector.class("hide-all")
//
//  public static func hide(_ breakpoint: Breakpoint) -> CssSelector {
//    return .class("hide-\(breakpoint.rawValue)")
//  }
//}
//
//public let hideStyles: Stylesheet =
//  hideAllStyles
//    <> responsiveStyles
//
//private let hideAllStyles =
//  Class.hide % (
//    position(.absolute)
//      <> height(.px(1))
//      <> width(.px(1))
//      <> overflow(.hidden)
//      <> clip(rect(top: .px(1), right: .px(1), bottom: .px(1), left: .px(1)))
//)
//
//private let responsiveStyles: Stylesheet =
//  Breakpoint.all.map { breakpoint in
//    breakpoint.query(only: screen) {
//      Class.hide(breakpoint) % display(.none)
//    }
//    }
//    .concat()
//
