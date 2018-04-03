import Either
import Html
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

PlaygroundPage.current.needsIndefiniteExecution = true

let htmlNodes = newEpisodeEmail.view(
  (
    ep10,
    "",
    "",
    .nonSubscriber
  )
)
let htmlString = render(htmlNodes, config: compact)

let webView = WKWebView(
  frame: .init(x: 0, y: 0, width: 400, height: 750)
)
webView.loadHTMLString(htmlString, baseURL: nil)
print(htmlString)

PlaygroundPage.current.liveView = webView
