import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import WebKit

Current = .mock

let req = request(to: .account(.invoices(.index)), session: .loggedIn)
let result = siteMiddleware(connection(from: req)).perform()
let htmlStr = String(data: result.response.body, encoding: .utf8)!

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 376, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView
