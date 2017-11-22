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

public let typeScaleStyles =
       Class.h1 % fontSize(.rem(3.998))
    <> Class.h2 % fontSize(.rem(2.827))
    <> Class.h3 % fontSize(.rem(1.999))
    <> Class.h4 % fontSize(.rem(1.414))
    <> Class.h5 % fontSize(.rem(1.0))
    <> Class.h6 % fontSize(.rem(0.707))
