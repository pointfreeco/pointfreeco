import Css
import Foundation
import Html
import Prelude

public let grid =
  resets
    <> gridStyles
    <> parentColumnStyles
    <> columnStyles

private let resets =
  body % boxSizing(.borderBox)
    <> (.star | .star & .pseudoElem(.before) | .star & .pseudoElem(.after)) % boxSizing(.inherit)

private let numColumns = 12

private let parentColumnStyles: Stylesheet = colClass % (
  flex(grow: 1, shrink: 1, basis: 0)
    <> maxWidth(.pct(100))
)

private let columnStyles: Stylesheet =
  (1...numColumns).map { idx in
    .class("col-\(idx)") % (
      _flex(basis: (Double(idx) / Double(numColumns)) * .pct(100))
        <> maxWidth((Double(idx) / Double(numColumns)) * .pct(100))
    )
    }
    .reduce(.empty, <>)

private let gridStyles: Stylesheet =
  gridClass % (
    display(.flex)
      <> margin(topBottom: 0, leftRight: .auto)
      <> overflow(.hidden)
)

public let gridClass = CssSelector.class("grid")
public let colClass = CssSelector.class("col")
public let col1Class = CssSelector.class("col-1")
public let col2Class = CssSelector.class("col-2")
public let col3Class = CssSelector.class("col-3")
public let col4Class = CssSelector.class("col-4")
public let col5Class = CssSelector.class("col-5")
public let col6Class = CssSelector.class("col-6")
public let col7Class = CssSelector.class("col-7")
public let col8Class = CssSelector.class("col-8")
public let col9Class = CssSelector.class("col-9")
public let col10Class = CssSelector.class("col-10")
public let col11Class = CssSelector.class("col-11")
public let col12Class = CssSelector.class("col-12")

// TODO: add to swift-web
@testable import Css
public func _flex(
  grow: Int? = nil,
  shrink: Int? = nil,
  basis: Css.Size? = nil
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

// TODO: move to swift-web
public func backgroundColor(_ color: Color) -> Stylesheet {
  return key("background-color")(color)
}

public struct Overflow: Val, Other, Auto, Inherit, Hidden, Visible {
  let overflow: Css.Value

  public func value() -> Css.Value {
    return self.overflow
  }

  public static func other(_ other: Css.Value) -> Overflow {
    return .init(overflow: other)
  }

  public static let auto: Overflow = .init(overflow: .auto)
  public static let inherit: Overflow = .init(overflow: .inherit)
  public static let hidden: Overflow = .init(overflow: .hidden)
  public static let visible: Overflow = .init(overflow: .visible)
  public static let scroll: Overflow = .init(overflow: "scroll")
}

public func overflow(_ overflow: Overflow) -> Stylesheet {
  return key("overflow")(overflow)
}

public func overflow(x: Overflow? = nil, y: Overflow? = nil) -> Stylesheet {
  return [ x.map { key("overflow-x", $0) },
           y.map { key("overflow-y", $0) } ]
    |> catOptionals
    |> concat
}

// TODO: move to a support package in swift-web
@testable import Css

public func `class`<T>(_ selectors: [CssSelector]) -> Attribute<T> {
  return .init(
    "class",
    selectors
      .map { renderSelector(inline, $0).replacingOccurrences(of: ".", with: "") }
      .joined(separator: " ")
  )
}
