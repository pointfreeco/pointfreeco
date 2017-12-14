import Css
import Prelude

public enum Dimension: String {
  case x
  case y
}

extension Class {
  public enum layout {
    public static let fit = CssSelector.class("fit")
    public static let inline = CssSelector.class("inline")
    public static let block = CssSelector.class("block")
    public static let inlineBlock = CssSelector.class("inline-block")
    public static let overflowHidden = CssSelector.class("overflow-hidden")
    public static let overflowScroll = CssSelector.class("overflow-scroll")
    public static let overflowAuto = CssSelector.class("overflow-auto")
    public static func overflowAuto(_ dim: Dimension) -> CssSelector {
      return CssSelector.class("overflow-auto-\(dim)")
    }
    public static let clearFix = CssSelector.class("clear-fix")
    public static let left = CssSelector.class("left")
    public static let right = CssSelector.class("right")
  }
}

public let layoutStyles =
  Class.layout.inline % display(.inline)
    <> Class.layout.block % display(.block)
    <> Class.layout.inlineBlock % display(.inlineBlock)
    <> ".table" % display(.table)
    <> ".table-cell" % display(.tableCell)
    <> Class.layout.overflowHidden % overflow(.hidden)
    <> Class.layout.overflowScroll % overflow(.scroll)
    <> Class.layout.overflowAuto % overflow(.auto)
    <> Class.layout.overflowAuto(.x) % overflow(x: .auto)
    <> Class.layout.overflowAuto(.y) % overflow(y: .auto)
    <> clearFixStyles
    <> floatStyles
    <> widthStyles
    <> ".border-box" % boxSizing(.borderBox)

private let clearFixStyles =
  (Class.layout.clearFix & .pseudoElem(.before) | Class.layout.clearFix & .pseudoElem(.after)) % (
    content(stringContent(""))
      <> display(.table)
  )
  <> (Class.layout.clearFix & .pseudoElem(.after)) % clear(.both)

private let floatStyles =
       Class.layout.left % float(.left)
    <> Class.layout.right % float(.right)

private let widthStyles =
  Class.layout.fit % maxWidth(.pct(100))
