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
#if !os(Linux)
  import WebKit
#endif

class EpisodeTests: TestCase {
  func testHome() {
    let request = URLRequest(url: URL(string: url(to: .episode(.left(episodes.first!.slug))))!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView)
      }
    #endif
  }
}
