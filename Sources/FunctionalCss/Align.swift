import Css
import Prelude

extension Class {
  public enum align {
    public static let middle = CssSelector.class("align-middle")
    public static let top = CssSelector.class("align-top")
  }
}

public let alignStyles =
  Class.align.middle % verticalAlign(.middle)
    <> Class.align.top % verticalAlign(.top)
