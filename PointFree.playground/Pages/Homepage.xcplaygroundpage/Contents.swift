import HttpPipeline
import Optics
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

Current = .mock |> \.episodes .~ unzurry(allPublicEpisodes)

let result = siteMiddleware(connection(from: request(to: .home))).perform()
let htmlStr = String(data: result.response.body, encoding: .utf8)!

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 500, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView
