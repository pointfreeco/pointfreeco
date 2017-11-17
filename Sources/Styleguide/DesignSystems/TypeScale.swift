import Css
import Prelude

public enum HeaderClass {
  public static let h1 = CssSelector.class("h1")
  public static let h2 = CssSelector.class("h")
  public static let h3 = CssSelector.class("h3")
  public static let h4 = CssSelector.class("h4")
  public static let h5 = CssSelector.class("h5")
  public static let h6 = CssSelector.class("h6")
}

public let typeScale =
  HeaderClass.h1 % fontSize(.rem(2))
    <> HeaderClass.h2 % fontSize(.rem(1.5))
    <> HeaderClass.h3 % fontSize(.rem(1.25))
    <> HeaderClass.h4 % fontSize(.rem(1))
    <> HeaderClass.h5 % fontSize(.rem(0.875))
    <> HeaderClass.h6 % fontSize(.rem(0.75))
