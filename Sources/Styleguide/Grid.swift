import Css
import Foundation
import Html
import Prelude

public let grid = Stylesheet.empty
//  resets
//    <> gridStyles
//    <> parentColumnStyles
//    <> columnStyles
//
//private let resets =
//  body % boxSizing(.borderBox)
//    <> (.star | .star & .pseudoElem(.before) | .star & .pseudoElem(.after)) % boxSizing(.inherit)
//
//private let numColumns = 12
//
//private let parentColumnStyles: Stylesheet = colClass % (
//  flex(grow: 1, shrink: 1, basis: 0)
//    <> maxWidth(.pct(100))
//)
//
//private let columnStyles: Stylesheet =
//  (1...numColumns).map { idx in
//    .class("col-\(idx)") % (
//      _flex(basis: (Double(idx) / Double(numColumns)) * .pct(100))
//        <> maxWidth((Double(idx) / Double(numColumns)) * .pct(100))
//    )
//    }
//    .reduce(.empty, <>)
//
//private let gridStyles: Stylesheet =
//  gridClass % (
//    display(.flex)
//      <> margin(topBottom: 0, leftRight: .auto)
//      <> overflow(.hidden)
//)
//
//public let gridClass = CssSelector.class("grid")
//public let colClass = CssSelector.class("col")
//public let col1Class = CssSelector.class("col-1")
//public let col2Class = CssSelector.class("col-2")
//public let col3Class = CssSelector.class("col-3")
//public let col4Class = CssSelector.class("col-4")
//public let col5Class = CssSelector.class("col-5")
//public let col6Class = CssSelector.class("col-6")
//public let col7Class = CssSelector.class("col-7")
//public let col8Class = CssSelector.class("col-8")
//public let col9Class = CssSelector.class("col-9")
//public let col10Class = CssSelector.class("col-10")
//public let col11Class = CssSelector.class("col-11")
//public let col12Class = CssSelector.class("col-12")

// TODO: move to a support package in swift-web
public func `class`<T>(_ selectors: [CssSelector]) -> Attribute<T> {
  return .init(
    "class",
    selectors
      .map { renderSelector($0).replacingOccurrences(of: ".", with: "") }
      .joined(separator: " ")
  )
}
