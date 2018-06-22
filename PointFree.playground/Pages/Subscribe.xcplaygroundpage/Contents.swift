import HttpPipeline
import Optics
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

Current = .mock

var request = PointFreeTestSupport.request(to: .pricing(nil, expand: nil))

let result = siteMiddleware(connection(from: request)).perform()
let htmlStr = String(data: result.response.body, encoding: .utf8) ?? ""

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 376, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)
print(htmlStr)

PlaygroundPage.current.liveView = webView
