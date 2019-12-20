import HtmlUpgrade

public func addGoogleAnalytics(_ node: Node) -> Node {
  switch node {
  case .comment:
    return node
  case let .element(tag, attribs, child):
    return Node.element(
      tag,
      attribs,
      tag == "head"
        ? .fragment([child, googleAnalytics])
        : addGoogleAnalytics(child)
    )
  case .doctype, .raw, .text:
    return node

  case let .fragment(nodes):
    return .fragment(nodes.map(addGoogleAnalytics))
  }
}

private let googleAnalytics = Node.script(
  safe: """
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');\
ga('create', 'UA-106218876-1', 'auto');\
ga('send', 'pageview');
""")
