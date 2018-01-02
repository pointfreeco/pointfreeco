import Css
import Prelude

extension Class {
  public enum cursor {
    public static let pointer = CssSelector.class("cursor-pointer")
  }
}

let cursorStyles =
  Class.cursor.pointer % key("cursor", "pointer")
