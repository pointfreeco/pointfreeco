import Html
import Optics
import Prelude

public func addGoogleAnalytics(_ nodes: [Node]) -> [Node] {
  return nodes.map { node in
    switch node {
    case .comment:
      return node
    case let .document(doc):
      return .document(addGoogleAnalytics(doc))
    case let .element(element):
      if element.name == "head" {
        return .element(element |> \.content %~ { ($0 ?? []) + [googleAnalytics] })
      } else {
        return .element(element |> \.content %~ map(addGoogleAnalytics))
      }
    case .text:
      return node
    }
  }
}

private let googleAnalytics = script <|
"""
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');\
ga('create', 'UA-106218876-1', 'auto');\
ga('send', 'pageview');
"""
