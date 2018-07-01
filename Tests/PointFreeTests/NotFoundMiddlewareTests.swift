import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

final class NotFoundMiddlewareTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
  }

  func testNotFound() {
    let result = connection(from: URLRequest(url: URL(string: "http://localhost:8080/404")!))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1000))
      webView.loadHTMLString(String(decoding: result.data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testNotFound_LoggedIn() {
    let result = connection(
      from: request(to: .home, session: .loggedIn)
        |> (over(\.url) <<< map) %~ { $0.appendingPathComponent("404") }
      )
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1000))
      webView.loadHTMLString(String(decoding: result.data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }
}
