import Either
import Html
import Models
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

PlaygroundPage.current.needsIndefiniteExecution = true

let htmlNodes = newBlogPostEmail(
  (
    post0005_stylingWithFunctions,
    "Announcement for subscribers",
    "Announcement for non-subscribers",
    .nonSubscriber
  )
)
let htmlString = render(htmlNodes)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 400, height: 750))
webView.loadHTMLString(htmlString, baseURL: nil)
PlaygroundPage.current.liveView = webView
