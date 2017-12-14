import Css
import Prelude

extension Class {
  public enum display {
    public static let block = CssSelector.class("block")
    public static let inline = CssSelector.class("inline")
    public static let inlineBlock = CssSelector.class("inline-block")
    public static let none = CssSelector.class("none")
    public static let table = CssSelector.class("table")
    public static let tableCell = CssSelector.class("table-cell")
  }
}

public let displayStyles =
  Class.display.inline % display(.inline)
    <> Class.display.block % display(.block)
    <> Class.display.inlineBlock % display(.inlineBlock)
    <> Class.display.none % display(.none)
    <> Class.display.table % display(.table)
    <> Class.display.tableCell % display(.tableCell)
