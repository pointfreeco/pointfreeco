import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
@testable import HttpPipeline
import HttpPipelineTestSupport
import Optics
import WebKit

class EpisodeTests: TestCase {
  func testHome() {
    let request = URLRequest(url: URL(string: url(to: Route.episode(.left(episodes.first!.slug))))!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1800))
    webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
    if #available(OSX 10.13, *) {
      assertSnapshot(matching: webView)
    }
  }
}
