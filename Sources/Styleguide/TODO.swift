@testable import Css
@testable import Html
import Foundation
import Prelude

// TODO: move to swift-web/Display
public struct Clip: Val, Other, Auto, Inherit {
  let clip: Css.Value

  public func value() -> Css.Value {
    return self.clip
  }

  public static func other(_ other: Css.Value) -> Clip {
    return .init(clip: other)
  }

  public static let auto = Clip(clip: "auto")
  public static let inherit = Clip(clip: "inherit")
}

public func clip(_ clip: Clip) -> Stylesheet {
  return key("clip")(clip)
}

public func rect(top: Css.Size, right: Css.Size, bottom: Css.Size, left: Css.Size) -> Clip {
  return Clip(
    clip: Value(
      [
        "rect(",
        top.value().unValue,
        right.value().unValue,
        bottom.value().unValue,
        left.value().unValue,
        ")"
        ]
        .concat()
    )
  )
}

// TODO: move to swift-web
extension Display {
  public static let inline: Display = "inline"
  public static let tableCell: Display = "table-cell"
}

public func render(classes: [CssSelector]) -> String {
  return classes.map(render(class:)).joined(separator: " ")
}

public func render(class selector: CssSelector) -> String {
  switch selector {
  case .star, .elem, .id, .pseudo, .pseudoElem, .attr, .child, .sibling, .deep, .adjacent, .combined:
    return ""
  case let .class(str):
    return str
  case let .union(lhs, rhs):
    return render(class: lhs) + " " + render(class: rhs)
  }
}

// TODO: move to a support package in swift-web
public func `class`<T>(_ selectors: [CssSelector]) -> Attribute<T> {
  return .init(
    "class",
    render(classes: selectors)
  )
}

// TODO: make Css.key function public
// TODO: move to swift-web
private let mainElement = CssSelector.Element.other("main")
public let main = CssSelector.elem(mainElement)
private let hrElement = CssSelector.Element.other("hr")
public let hr = CssSelector.elem(hrElement)
private let subElement = CssSelector.Element.other("sub")
public let sub = CssSelector.elem(subElement)
private let supElement = CssSelector.Element.other("sup")
public let sup = CssSelector.elem(supElement)
private let svgElement = CssSelector.Element.other("svg")
public let svg = CssSelector.elem(svgElement)


private let buttonElement = CssSelector.Element.other("button")
public let button = CssSelector.elem(buttonElement)
private let optgroupElement = CssSelector.Element.other("optgroup")
public let optgroup = CssSelector.elem(optgroupElement)
private let selectElement = CssSelector.Element.other("select")
public let select = CssSelector.elem(selectElement)
private let textareaElement = CssSelector.Element.other("textarea")
public let textarea = CssSelector.elem(textareaElement)

extension Color {
  public static let transparent = Color.other("transparent")
}

extension Position {
  public static let sticky: Position = "sticky"
}

extension FontStyle {
  public static let italic = FontStyle(style: "italic")
}

public func li<T: ContainsList>(_ attribs: [Attribute<Element.Li>]) -> ([Node]) -> ChildOf<T> {
  return { .init(node("li", attribs, $0)) }
}
