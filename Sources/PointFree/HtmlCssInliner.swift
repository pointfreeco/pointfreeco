import Css
import Html
import Optics
import Prelude

/// Transforms `node` by applying a reasonable number of the styles from `stylesheet` to each element.
public func applyInlineStyles(node: Node, stylesheet: Stylesheet) -> Node {
  switch node {
  case let .element(tag, attribs, child):
    return applyInlineStyles(tag: tag, attribs: attribs, child: child, stylesheet: stylesheet)

  case .comment, .doctype, .raw, .text:
    return node

  case let .fragment(children):
    return .fragment(children.map { applyInlineStyles(node: $0, stylesheet: stylesheet) })
  }
}

private func applyInlineStyles(
  tag: String,
  attribs: [(key: String, value: String?)],
  child: Node,
  stylesheet: Stylesheet
) -> Node {

  let currentStyles = attribs.first(where: { $0.key == "style" })?.value ?? ""

  // Computes all inline styles based on the classes on this element
  let classStyles = (attribs.first(where: { $0.key == "class" })?.value ?? "")
    .components(separatedBy: " ")
    .map { inlineStyles(for: .class($0), stylesheet: stylesheet) }
    .joined(separator: ";")

  // Computes all inline styles based on the name of the element tag.
  let elemStyles = inlineStyles(for: .elem(.other(tag)), stylesheet: stylesheet)

  // Computes all inline styles based on the id of the element.
  let idStyles = (attribs.first(where: { $0.key == "id" })?.value)
    .map { inlineStyles(for: .id($0), stylesheet: stylesheet) }
    ?? ""

  let newStyles = [
    elemStyles,
    classStyles,
    idStyles,
    currentStyles,
    ]
    .filter { !$0.isEmpty }
    .joined(separator: ";")

  let newAttribs = attribs
    .filter { $0.key != "style" }
    + (newStyles.isEmpty ? [] : [("style", newStyles)])

  return .element(
    tag,
    newAttribs,
    applyInlineStyles(node: child, stylesheet: stylesheet)
  )
}

// Computes the inline styles for a selector given a stylesheet.
private func inlineStyles(for selector: CssSelector, stylesheet: Stylesheet) -> String {
  return stylesheet.rules // TODO: make rules public
    .lazy
    .map { inlineStyles(for: selector, rule: $0) }
    .filter { !$0.isEmpty }
    .joined(separator: ";")
}

// Computes the inline styles for a selector given a single styling rule.
private func inlineStyles(for selector: CssSelector, rule: Rule) -> String {
  switch rule {
  case let .property(key, value):
    return Css.renderRule(.inline, [], [(key, value)])

  case let .nested(app, rules):
    if doesApp(app, contain: selector) {
      return rules
        .map { inlineStyles(for: selector, rule: $0) }
        .joined(separator: ";")
    }
    return ""

  case .query, .face, .keyframe, .import:
    // TODO: what to do about `query` here? Media queries can't be used in inline styles, but we might still
    //       want to render its styles?
    return ""
  }
}

// TODO: make App public

// Attempts to determine if the `app` passed in matches the selector. We make a simplifying assumption
// here to only deal with flat stylesheets, i.e. no nesting.
private func doesApp(_ app: App, contain selector: CssSelector) -> Bool {
  switch app {
  case let .sub(subSelector):
    return doesSelector(subSelector, contain: selector)
  default:
    return false
  }
}

// Naive attempt to determine if `selector` contains `otherSelector`, i.e. `selector` matches everything
// `otherSelector` matches (and possibly more). For example, the selector `a | p` contains the selector
// `p`.
private func doesSelector(_ selector: CssSelector, contain otherSelector: CssSelector) -> Bool {

  // Simple way to turn element into string that properly takes care of the `other` case. The
  // `CssSelector.Element` type should prob just be a struct.
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

  case let (.union(sel1, sel2), _):
    return doesSelector(sel1, contain: otherSelector) || doesSelector(sel2, contain: otherSelector)

  default:
    return false
  }
}
