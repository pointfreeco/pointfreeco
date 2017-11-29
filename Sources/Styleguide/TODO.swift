import Css
import Html
import Foundation
import Prelude

// TODO: move to swift-web

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

// this is just a curried version of `li`. i wasnt able to use `curry(li)` cause the compiler was confused by
// the `ChildOf` stuff. 
public func li<T: ContainsList>(_ attribs: [Attribute<Element.Li>]) -> ([Node]) -> ChildOf<T> {
  return { .init(node("li", attribs, $0)) }
}

public func opacity(_ value: Double) -> Stylesheet {
  return key("opacity")(value)
}
