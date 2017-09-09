import Css
import Prelude

private let rowBase = "row"
private let columnBase = "column"
private let offsetBase = "offset"

private let rowSelector: CssSelector = .class(rowBase)
private let columnSelector: CssSelector = .class(columnBase)

private let gridColumnCount = 12
private let columnMargin = 1.5
private let minimumColumnWidth: Double =
  (100 - (columnMargin * (Double(gridColumnCount) - 1.0))) / Double(gridColumnCount)

private func columnWidth(columnCount: Int) -> Double {
  return minimumColumnWidth * Double(columnCount) + columnMargin * (Double(columnCount) - 1)
}

private func columnSelector(_ n: Int) -> CssSelector {
  return .class("\(columnBase)-\(n)")
}

private func offsetSelector(_ n: Int) -> CssSelector {
  return .class("\(offsetBase)-\(n)")
}

let columns: Stylesheet = concat(
  (1...gridColumnCount)
    .map { n in
      columnSelector(n) % width(.pct(columnWidth(columnCount: n)))
  }
)

let offsets: Stylesheet = concat(
  (1..<gridColumnCount)
    .map { n in
      offsetSelector(n) % margin(left: .pct(columnWidth(columnCount: n) + columnMargin))
  }
)

let responsive: Stylesheet = queryOnly(screen, [maxWidth(.px(550))]) {
  concat((2...gridColumnCount).map(columnSelector), .class("\(columnBase)-1")) % (
    width(.auto)
      <> float(.none)
    )
    <> (columnSelector + columnSelector) % margin(left: 0)
}

public let gridSystem: Stylesheet =
  (rowSelector | columnSelector) % (
    boxSizing(.borderBox)
  )
  <> (rowSelector & .pseudoElem(.before) | rowSelector & .pseudoElem(.after)) % (
    content(stringContent(" "))
      <> display(.table)
  )
  <> (rowSelector & .pseudoElem(.after)) % (
    clear(.both)
  )
  <> columnSelector % (
    position(.relative)
      <> float(.left)
      <> display(.block)
  )
  <> (columnSelector + columnSelector) % (
    margin(left: .pct(columnMargin))
  )
  <> columns
  <> offsets
  <> responsive

