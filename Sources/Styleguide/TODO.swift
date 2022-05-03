import Css
import Foundation
import FunctionalCss
import Html
import Prelude

extension Attribute {
  // TODO: move to a support package in swift-web
  public static func `class`<T>(_ selectors: [CssSelector]) -> Attribute<T> {
    return .init(
      "class",
      render(classes: selectors)
    )
  }
}

extension Attribute {
  public static func style(_ style: Stylesheet) -> Attribute<Element> {
    return .style(unsafe: render(config: Config.inline, css: style))
  }
}

extension ChildOf where Element == Tag.Head {
  public static func style(
    _ css: Stylesheet,
    config: Css.Config = .compact
  ) -> ChildOf<Tag.Head> {
    return .style(unsafe: render(config: config, css: css))
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
