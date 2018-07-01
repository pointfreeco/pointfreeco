import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import WebKit

Current = .mock

let req = request(to: .account(.index), session: .loggedIn)
let result = siteMiddleware(connection(from: req)).perform()
let htmlStr = String(decoding: result.response.body, as: UTF8.self)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView
