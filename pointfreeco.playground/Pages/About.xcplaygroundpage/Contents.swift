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

AppEnvironment.push(const(.mock))

let request = PointFreeTestSupport.request(to: .about)

let conn = connection(from: request)
let result = (conn |> siteMiddleware).perform()
let htmlStr = String(data: result.response.body, encoding: .utf8) ?? ""

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 850, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

print(htmlStr)

PlaygroundPage.current.liveView = webView
