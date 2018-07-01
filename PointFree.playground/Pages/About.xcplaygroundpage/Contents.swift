import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import WebKit

Current = .mock

let req = request(to: .about)

let result = siteMiddleware(connection(from: req)).perform()
let htmlStr = String(decoding: result.response.body, as: UTF8.self)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 376, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

print(htmlStr)

PlaygroundPage.current.liveView = webView
