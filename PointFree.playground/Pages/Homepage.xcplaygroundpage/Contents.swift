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

Current = .mock |> \.episodes .~ unzurry(allPublicEpisodes)

let result = connection(from: request(to: .home))
  |> siteMiddleware
  |> Prelude.perform
let htmlStr = String(data: result.response.body, encoding: .utf8)!

let webView = WKWebView(
  frame: .init(
    x: 0, y: 0, width: 500, height: 750
  )
)
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView
