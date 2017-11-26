import Css
import Prelude

extension Class {
  public static let layout = (
    fit: CssSelector.class("fit"),
    inline: CssSelector.class("inline"),
    block: CssSelector.class("inline"),
    inlineBlock: CssSelector.class("inline"),
    overflowHidden: CssSelector.class("overflow-hidden"),
    overflowScroll: CssSelector.class("overflow-scroll"),
    overflowAuto: CssSelector.class("overflow-auto"),
    clearFix: CssSelector.class("clear-fix"),
    left: CssSelector.class("left"),
    right: CssSelector.class("right")
  )
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
    <> ".max-width-1" % maxWidth(Breakpoint.xs.minSize)
    <> ".max-width-2" % maxWidth(Breakpoint.sm.minSize)
    <> ".max-width-3" % maxWidth(Breakpoint.md.minSize)
    <> ".max-width-4" % maxWidth(Breakpoint.lg.minSize)
