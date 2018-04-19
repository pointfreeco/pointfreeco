import Css
import CssReset
import Either
import Html
import HtmlCssSupport
import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit
import Optics
import SnapshotTesting
import Styleguide

let page = simplePageLayout(invoicesView).view(
  .init(
    currentUser: .mock,
    data: (.mock, .mock([.mock, .mock, .mock]), .mock),
    title: "Payment history"
  )
)

AppEnvironment.push(const(.mock))

let htmlStr = render(page, config: pretty)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView
