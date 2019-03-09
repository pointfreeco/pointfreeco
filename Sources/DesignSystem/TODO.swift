import Css

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

public func zIndex(_ n: Int) -> Stylesheet {
  return key("z-index", "\(n)")
}
