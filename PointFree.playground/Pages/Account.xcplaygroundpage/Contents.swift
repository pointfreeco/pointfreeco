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

Current = .mock

let htmlString = render(accountView.view((.mock, [.mock, .mock], [.mock, .mock, .mock], [.mock], [.mock], .mock)), config: pretty)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 750))
webView.loadHTMLString(htmlString, baseURL: nil)
//print(htmlString)

PlaygroundPage.current.liveView = webView
