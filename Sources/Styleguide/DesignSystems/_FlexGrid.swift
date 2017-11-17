import Css
import Prelude

public enum Breakpoint: String {
  case xs
  case sm
  case md
  case lg

  public var minSize: Size {
    switch self {
    case .xs:
      return .em(24)
    case .sm:
      return .em(40)
    case .md:
      return .em(52)
    case .lg:
      return .em(64)
    }
  }
}

private enum GridClass {
  static let row = CssSelector.class("row")
  static let col = CssSelector.class("col")

  static let reversed = CssSelector.class("reverse")

  static let rowReversed = row & reversed
  static let colReversed = col & reversed

  static func col(_ size: Breakpoint, _ n: Int?) -> CssSelector {
    return n.map { CssSelector.class("col-\(size)-\($0)") }
      ?? CssSelector.class("col-\(size)")
  }
}

public let flexGridStyles =
  rowStyle
    <> reversedRowStyle
    <> reversedColStyle
    <> styles(for: .xs)
    <> queryOnly(screen, [minWidth(Breakpoint.sm.minSize)]) { styles(for: .sm) }
    <> queryOnly(screen, [minWidth(Breakpoint.md.minSize)]) { styles(for: .md) }
    <> queryOnly(screen, [minWidth(Breakpoint.lg.minSize)]) { styles(for: .lg) }

private let rowStyle =
  ".row" % (
    boxSizing(.borderBox)
      <> display(.flex)
      <> flex(grow: 0, shrink: 1, basis: .auto)
      <> flex(direction: .row, wrap: .wrap)
)

private let reversedRowStyle =
  GridClass.rowReversed % (
    flex(direction: .rowReverse)
)

private let reversedColStyle =
  GridClass.colReversed % (
    flex(direction: .columnReverse)
)

private func styles(for breakpoint: Breakpoint) -> Stylesheet {

  let allColsSelector = (1...12)
    .map { GridClass.col(breakpoint, $0) }
    .reduce(GridClass.col(breakpoint, nil), |)

  let baseColStyles =
    allColsSelector % (
      boxSizing(.borderBox)
        <> flex(grow: 0, shrink: 0, basis: .auto)
  )

  let colStyles = GridClass.col(breakpoint, nil) % (
    flex(grow: 1, basis: 0)
      <> maxWidth(.pct(100))
    )
    <> (1...12).map { idx in
      GridClass.col(breakpoint, idx) % (
        flex(basis: .pct(100 * Double(idx) / 12))
          <> maxWidth(.pct(100 * Double(idx) / 12))
      )
      }
      .concat()

  let alignment =
    .class("start-\(breakpoint)") % (
      justify(content: .flexStart)
        <> textAlign(.start)
      )
      <> .class("center-\(breakpoint)") % (
        justify(content: .center)
          <> textAlign(.center)
      )
      <> .class("end-\(breakpoint)") % (
        justify(content: .flexEnd)
          <> textAlign(.end)
      )
      <> .class("top-\(breakpoint)") % align(items: .flexStart)
      <> .class("middle-\(breakpoint)") % align(items: .center)
      <> .class("bottom-\(breakpoint)") % align(items: .flexEnd)

  let distribution =
    .class("around-\(breakpoint)") % justify(content: .spaceAround)
      <> .class("between-\(breakpoint)") % justify(content: .spaceBetween)

  let orderStyles =
    .class("first-\(breakpoint)") % order(-1)
      <> .class("last-\(breakpoint)") % order(1)

  return baseColStyles
    <> colStyles
    <> alignment
    <> distribution
    <> orderStyles
}
