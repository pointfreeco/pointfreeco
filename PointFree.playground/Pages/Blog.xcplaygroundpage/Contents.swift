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

let post = AppEnvironment.current.blogPosts().first!
let req = request(to: .blog(.show(post)), session: .loggedOut, basicAuth: true)
let result = connection(from: req)
  |> siteMiddleware
  |> Prelude.perform
  |> ^\.response.body
let htmlStr = String(data: result, encoding: .utf8) ?? ""

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 400, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView

