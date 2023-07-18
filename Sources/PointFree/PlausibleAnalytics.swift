import Html

public func addPlausibleAnalytics(_ node: Node) -> Node {
  switch node {
  case .comment:
    return node
  case let .element(tag, attribs, child):
    return Node.element(
      tag,
      attribs,
      tag == "head"
        ? .fragment([child, plausibleAnalytics])
        : addPlausibleAnalytics(child)
    )
  case .doctype, .raw, .text:
    return node

  case let .fragment(nodes):
    return .fragment(nodes.map(addPlausibleAnalytics))
  }
}

private let plausibleAnalytics = Node.script(
  attributes: [
    .defer(true),
    .data("domain", "pointfree.co"),
    .src("https://plausible.io/js/script.js")
  ]
)
