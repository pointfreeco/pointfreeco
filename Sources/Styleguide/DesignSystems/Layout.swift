import Css
import Prelude

public let layoutStyles =
  ".inline" % display(.inline)
    <> ".block" % display(.block)
    <> ".inline-block" % display(.inlineBlock)
    <> ".table" % display(.table)
    <> ".table-cell" % display(.tableCell)
    <> ".overflow-hidden" % overflow(.hidden)
    <> ".overflow-scroll" % overflow(.scroll)
    <> ".overflow-auto" % overflow(.auto)
    <> clearFixStyles
    <> floatStyles
    <> widthStyles
    <> ".border-box" % boxSizing(.borderBox)

private let clearFixStyles =
  (".clearfix" & .pseudoElem(.before) | ".clearfix" & .pseudoElem(.after)) % (
    content(stringContent(""))
      <> display(.table)
  )
  <> (".clearfix" & .pseudoElem(.after)) % clear(.both)

private let floatStyles =
  ".left" % float(.left)
    <> ".right" % float(.right)

private let widthStyles =
  ".fit" % maxWidth(.pct(100))
    <> ".max-width-1" % maxWidth(Breakpoint.xs.minSize)
    <> ".max-width-2" % maxWidth(Breakpoint.sm.minSize)
    <> ".max-width-3" % maxWidth(Breakpoint.md.minSize)
    <> ".max-width-4" % maxWidth(Breakpoint.lg.minSize)

// TODO: move to swift-web
extension Display {
  public static let inline: Display = "inline"
  public static let tableCell: Display = "table-cell"
}
