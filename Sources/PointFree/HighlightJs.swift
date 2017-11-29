import Html
import Optics
import Prelude

/// Walks the node tree looking for the <head> tag, and once found adds the necessary script and stylesheet
/// tags for highlight.js
public func addHighlightJs(_ nodes: [Node]) -> [Node] {
  return nodes.map { node in
    switch node {
    case .comment:
      return node
    case let .document(doc):
      return .document(addHighlightJs(doc))
    case let .element(element):
      return element.name == "head"
        ? .element(element |> \.content %~ { ($0 ?? []) + highlightJsHead.map(get(\.node)) })
        : .element(element |> \.content %~ map(addHighlightJs))
    case .text:
      return node
    }
  }
}

private let highlightJsHead: [ChildOf<Element.Head>] = [
  link(
    [rel(.stylesheet), href("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css")]
  ),
  script([src("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js")]),
  script("hljs.initHighlightingOnLoad();")
]
