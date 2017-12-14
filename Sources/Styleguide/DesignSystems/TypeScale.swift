import Css
import Prelude

extension Class {
  public static let h1 = CssSelector.class("h1")
  public static let h2 = CssSelector.class("h2")
  public static let h3 = CssSelector.class("h3")
  public static let h4 = CssSelector.class("h4")
  public static let h5 = CssSelector.class("h5")
  public static let h6 = CssSelector.class("h6")
}

public let typescale =
  Class.h1 % fontSize(.rem(4))         // 64  56
    <> Class.h2 % fontSize(.rem(3))    // 48  42
    <> Class.h3 % fontSize(.rem(2))    // 32  28
    <> Class.h4 % fontSize(.rem(1.5))  // 24  21
    <> Class.h5 % fontSize(.rem(1.0))  // 16  14
    <> Class.h6 % fontSize(.rem(0.75)) // 12  11
