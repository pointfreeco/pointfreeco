import HttpPipeline
import Optics
@testable import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
  import WebKit
#endif
import XCTest

class EpisodeTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testEpisodePage() {
    let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedOut)

    let conn = connection(from: episode)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }

  func testEpisodePageSubscriber() {


    let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)

    let conn = connection(from: episode)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }

  func testEpisodeNotFound() {
    let request = URLRequest(url: URL(string: url(to: .episode(.left("object-oriented-programming"))))!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1000))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView)
      }
    #endif
  }
}
