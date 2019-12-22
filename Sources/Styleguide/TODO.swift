import Css
import FunctionalCss
import Html
import HtmlUpgrade
import Foundation
import Prelude

// TODO: move to a support package in swift-web
public func `class`<T>(_ selectors: [CssSelector]) -> Html.Attribute<T> {
  return .init(
    "class",
    render(classes: selectors)
  )
}

extension HtmlUpgrade.Attribute {
  // TODO: move to a support package in swift-web
  public static func `class`<T>(_ selectors: [CssSelector]) -> HtmlUpgrade.Attribute<T> {
    return .init(
      "class",
      render(classes: selectors)
    )
  }
}

extension HtmlUpgrade.Attribute {
  public static func style(_ style: Stylesheet) -> HtmlUpgrade.Attribute<Element> {
    return .style(unsafe: render(config: Config.inline, css: style))
  }
}

extension HtmlUpgrade.ChildOf where Element == HtmlUpgrade.Tag.Head {
  public static func style(
    _ css: Stylesheet,
    config: Css.Config = .compact
  ) -> HtmlUpgrade.ChildOf<HtmlUpgrade.Tag.Head> {
    return .style(unsafe: render(config: config, css: css))
  }
}


public func downgrade(node: HtmlUpgrade.Node) -> [Html.Node] {
  switch node {
  case let .comment(comment):
    return [.comment(comment)]
  case let .doctype(doctype):
    return [.doctype(doctype)]
  case let .element(tag, attrs, child):
    return [.element(tag, attrs, downgrade(node: child))]
  case let .fragment(children):
    return children.flatMap(downgrade(node:))
  case let .raw(value):
    return [.raw(value)]
  case let .text(value):
    return [.text(value)]
  }
}

public func upgrade(node: Html.Node) -> HtmlUpgrade.Node {
  switch node {
  case let .comment(comment):
    return [.comment(comment)]
  case let .doctype(doctype):
    return [.doctype(doctype)]
  case let .element(tag, attrs, children):
    return .element(tag, attrs, .fragment(children.map(upgrade(node:))))
  case let .raw(value):
    return [.raw(value)]
  case let .text(value):
    return [.text(value)]
  }
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

public func opacity(_ value: Double) -> Stylesheet {
  return key("opacity")(value)
}

public func bgcolor<T>(_ value: String) -> Html.Attribute<T> {
  return .init("bgcolor", value)
}
