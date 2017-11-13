import Css
import Prelude

public let grid =
  resets
    <> gridStyles
    <> columnStyles

private let resets =
  body % boxSizing(.borderBox)
    <> (.star | .star & .pseudoElem(.before) | .star & .pseudoElem(.after)) % boxSizing(.inherit)

private let numColumns = 12

private let columnStyles: Stylesheet = (1...numColumns).reduce(.empty) { accum, idx in
  accum
    <> CssSelector.class("col-\(idx)") % (
      _flex(basis: (Double(idx) / Double(numColumns)) * .pct(100))
        <> maxWidth((Double(idx) / Double(numColumns)) * .pct(100))
  )
}

private let gridStyles: Stylesheet =
  gridClass % (
    display(.flex)
      <> margin(topBottom: 0, leftRight: .auto)
      // TODO: overflow: hidden;
)

private let gridClass = CssSelector.class("grid")
private let colClass = CssSelector.class("col")
private let col1Class = CssSelector.class("col-1")
private let col2Class = CssSelector.class("col-2")
private let col3Class = CssSelector.class("col-3")
private let col4Class = CssSelector.class("col-4")
private let col5Class = CssSelector.class("col-5")
private let col6Class = CssSelector.class("col-6")
private let col7Class = CssSelector.class("col-7")
private let col8Class = CssSelector.class("col-8")
private let col9Class = CssSelector.class("col-9")
private let col10Class = CssSelector.class("col-10")
private let col11Class = CssSelector.class("col-11")
private let col12Class = CssSelector.class("col-12")

// TODO: add to swift-web
@testable import Css
private func _flex(
  grow: Int? = nil,
  shrink: Int? = nil,
  basis: Size? = nil
  )
  ->
  Stylesheet {

    return [
      grow.map(key("flex-grow")),
      shrink.map(key("flex-shrink")),
      basis.map(key("flex-basis"))
      ]
      |> catOptionals
      |> concat
}
