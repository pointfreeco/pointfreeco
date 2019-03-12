import Css
import Prelude

extension Class {
  public enum grid {
    public static let row = CssSelector.class("row")
    public static let col = CssSelector.class("col")

    public static let reversed = CssSelector.class("reverse")

    public static let rowReversed = row & reversed
    public static let colReversed = col & reversed

    public static func col(_ size: Breakpoint, _ n: Int?) -> CssSelector {
      return n.map { CssSelector.class("col-\(size.rawValue)-\($0)") }
        ?? CssSelector.class("col-\(size.rawValue)")
    }

    public static func start(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("start-\(size.rawValue)")
    }

    public static func center(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("center-\(size.rawValue)")
    }

    public static func end(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("end-\(size.rawValue)")
    }

    public static func top(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("top-\(size.rawValue)")
    }

    public static func middle(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("middle-\(size.rawValue)")
    }

    public static func bottom(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("bottom-\(size.rawValue)")
    }

    public static func around(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("around-\(size.rawValue)")
    }

    public static func between(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("between-\(size.rawValue)")
    }

    public static func first(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("first-\(size.rawValue)")
    }

    public static func last(_ size: Breakpoint) -> CssSelector {
      return CssSelector.class("last-\(size.rawValue)")
    }
  }
}

public let flexGridStyles =
  rowStyle
    <> reversedRowStyle
    <> reversedColStyle
    <> Breakpoint.all.map { breakpoint in
      breakpoint.querySelfAndBigger(only: screen) { styles(for: breakpoint) }
      }
      .concat()

private let rowStyle =
  Class.grid.row % (
    boxSizing(.borderBox)
      <> display(.flex)
      <> flex(grow: 0, shrink: 1, basis: .auto)
      <> flex(direction: .row, wrap: .wrap)
)

private let reversedRowStyle =
  Class.grid.rowReversed % (
    flex(direction: .rowReverse)
)

private let reversedColStyle =
  Class.grid.colReversed % (
    flex(direction: .columnReverse)
)

private func styles(for breakpoint: Breakpoint) -> Stylesheet {

  let allColsSelector = (1...12)
    .map { Class.grid.col(breakpoint, $0) }
    .reduce(Class.grid.col(breakpoint, nil), |)

  let baseColStyles =
    allColsSelector % (
      boxSizing(.borderBox)
        <> flex(grow: 0, shrink: 0, basis: .auto)
  )

  let cols = (1...12).map { idx -> Stylesheet in
    Class.grid.col(breakpoint, idx) % (
      flex(basis: .pct(100 * Double(idx) / 12))
        <> maxWidth(.pct(100 * Double(idx) / 12))
    )
    }
    .concat()

  let colStyles = Class.grid.col(breakpoint, nil) % (
    flex(grow: 1, basis: 0)
      <> maxWidth(.pct(100))
    )
    <> cols

  let alignment =
    Class.grid.start(breakpoint) % (
      justify(content: .flexStart)
        <> textAlign(.start)
      )
      <> Class.grid.center(breakpoint) % (
        justify(content: .center)
          <> textAlign(.center)
      )
      <> Class.grid.end(breakpoint) % (
        justify(content: .flexEnd)
          <> textAlign(.end)
      )
      <> Class.grid.top(breakpoint) % align(items: .flexStart)
      <> Class.grid.middle(breakpoint) % align(items: .center)
      <> Class.grid.bottom(breakpoint) % align(items: .flexEnd)

  let distribution =
    Class.grid.around(breakpoint) % justify(content: .spaceAround)
      <> Class.grid.between(breakpoint) % justify(content: .spaceBetween)

  let orderStyles =
    Class.grid.first(breakpoint) % order(-1)
      <> Class.grid.last(breakpoint) % order(1)

  return baseColStyles
    <> colStyles
    <> alignment
    <> distribution
    <> orderStyles
}
