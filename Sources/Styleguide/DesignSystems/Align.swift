import Css
import Prelude

extension Class {
  public enum align {
    public static let middle = CssSelector.class("align-middle")
  }
}

public let alignStyles =
  Class.align.middle % verticalAlign(.middle)
