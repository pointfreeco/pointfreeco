@testable import Css
import Either
import Html
import HtmlCssSupport
import Optics
import PlaygroundSupport
@testable import PointFree
import Prelude
import Styleguide
import WebKit

PlaygroundPage.current.needsIndefiniteExecution = true

func applyInlineStyles(nodes: [Node], stylesheet: Stylesheet) -> [Node] {
  return nodes.map { applyInlineStyles(node: $0, stylesheet: stylesheet) }
}

func applyInlineStyles(node: Node, stylesheet: Stylesheet) -> Node {

  switch node {
  case .comment:
    return node

  case let .document(nodes):
    return .document(applyInlineStyles(nodes: nodes, stylesheet: stylesheet))

  case let .element(element):
    return .element(applyInlineStyles(element: element, stylesheet: stylesheet))

  case .text:
    return node
  }

  return node
}

func applyInlineStyles(element: Element, stylesheet: Stylesheet) -> Element {
  let currentStyles = element.attribs
    .first(where: { $0.key == "style" })?
    .value
    .renderedValue()?
    .string
    ?? ""

  let classes = (
    element.attribs
      .first(where: { $0.key == "class" })?
      .value
      .renderedValue()?
      .string
      ?? ""
    )
    .components(separatedBy: " ")

  let newStyles = currentStyles
    + classes
      .map { inlineStyles(for: .class($0), stylesheet: stylesheet) }
      .joined(separator: ";")
    + inlineStyles(for: .elem(.other(element.name)), stylesheet: stylesheet)

  let newAttribs = element.attribs
    .filter { $0.key != "style" }
    + (newStyles.isEmpty ? [] : [AnyAttribute("style", newStyles)])

  return element
    |> \.attribs .~ newAttribs
    |> \.content .~ applyInlineStyles(nodes: element.content ?? [], stylesheet: stylesheet)
}

func inlineStyles(for selector: CssSelector, stylesheet: Stylesheet) -> String {
  return stylesheet.rules
    .lazy
    .map { inlineStyles(for: selector, rule: $0) }
    .filter { !$0.isEmpty }
    .joined(separator: ";")
}

func inlineStyles(for selector: CssSelector, rule: Rule) -> String {
  switch rule {
  case let .property(key, value):
    return Css.rule(inline, [], [(key, value)])

  case let .nested(app, rules):
    if _app(app, contains: selector) {
      return rules
        .map { inlineStyles(for: selector, rule: $0) }
        .joined(separator: ";")
    }
    return ""

  case .query, .face, .keyframe, .import:
    return ""
  }
}

func _app(_ app: App, contains selector: CssSelector) -> Bool {
  switch app {
  case let .sub(subSelector):
    return _selector(subSelector, contains: selector)
  default:
    return false
  }
}

func _selector(_ selector: CssSelector, contains otherSelector: CssSelector) -> Bool {

  func toString(elem: CssSelector.Element) -> String {
    switch elem {
    case let .other(other):
      return other
    default:
      return "\(elem)"
    }
  }

  switch (selector, otherSelector) {
  case let (.elem(lhs), .elem(rhs)):
    return toString(elem: lhs) == toString(elem: rhs)
  case let (.class(lhs), .class(rhs)):
    return lhs == rhs
  case let (.id(lhs), .id(rhs)):
    return lhs == rhs
  case let (_, .union(sel1, sel2)):
    return _selector(selector, contains: sel1) || _selector(selector, contains: sel2)
  default:
    return false
  }
}

func classNames(app: App) -> [String] {
  switch app {
  case let .self(selector):
    return classNames(selector: selector)
  case let .root(selector):
    return classNames(selector: selector)
  case .pop:
    return []
  case let .child(selector):
    return classNames(selector: selector)
  case let .sub(selector):
    return classNames(selector: selector)
  }
}

func classNames(selector: CssSelector) -> [String] {
  switch selector {
  case let .class(name):
    return [name]
  case let .union(lhs, rhs):
    return classNames(selector: lhs) + classNames(selector: rhs)
  default:
    return []
  }
}

func elementNames(app: App) -> [String] {
  switch app {
  case let .self(selector):
    return elementNames(selector: selector)
  case let .root(selector):
    return elementNames(selector: selector)
  case .pop:
    return []
  case let .child(selector):
    return elementNames(selector: selector)
  case let .sub(selector):
    return elementNames(selector: selector)
  }
}

func elementNames(selector: CssSelector) -> [String] {
  switch selector {
  case let .class(name):
    return [name]
  case let .union(lhs, rhs):
    return elementNames(selector: lhs) + elementNames(selector: rhs)
  default:
    return []
  }
}

let doc = document([
  html([
    head([
      style(designSystems),
      style(emailBaseStyles),
      ]),
    body([
      h1([`class`([Class.pf.type.title1])], ["Hello world!"]),
      p([`class`([Class.pf.type.body.leading])], ["Aenean enim enim, maximus vel turpis at, lacinia blandit orci. Donec id ornare nibh. Aenean luctus nulla vitae orci molestie, in mollis enim bibendum. Duis tempor ac augue a ullamcorper."]),
      p([`class`([Class.pf.type.body.regular])], [
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur odio turpis, consectetur iaculis diam sed, luctus tristique mi. Vestibulum aliquam lectus vitae sodales interdum. Etiam semper mi ac ex laoreet, sed tempus ligula egestas. Donec rhoncus, purus eu facilisis mollis, odio ipsum ullamcorper velit, ut ultrices arcu massa quis tellus. Aenean placerat sapien ligula, ut congue nisi hendrerit ut. Nam sed urna magna. Integer porta feugiat quam, id vehicula dolor elementum sed. Nullam ultrices varius mi, eu congue lectus cursus in."
        ]),
      p([`class`([Class.padding([.mobile: [.topBottom: 3]])])], [
        a([href("#"), `class`([Class.pf.components.button(color: .purple)])], ["Click here!"])
        ])
      ])
    ])
  ])

let docWithInlineStyles = applyInlineStyles(
  node: doc,
  stylesheet: designSystems <> pointFreeBaseStyles
)

let htmlWithInlineStyles = render(docWithInlineStyles, config: pretty)
print(htmlWithInlineStyles)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 400, height: 750))
webView.loadHTMLString(htmlWithInlineStyles, baseURL: nil)

PlaygroundPage.current.liveView = webView

sendEmail(
  to: [EmailAddress(unwrap: "mbw234@gmail.com")],
  subject: "Foo 8",
  content: inj2([docWithInlineStyles])
  )
  .run
  .perform()
//


