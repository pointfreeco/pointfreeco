import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics
#if !os(Linux)
  import WebKit
#endif

class PricingTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testPricing() {
    let request = URLRequest(url: URL(string: url(to: .pricing(nil, nil)))!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1200))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.evaluateJavaScript(
          """
          document.getElementById("tab0").checked = false;
          document.getElementById("tab1").checked = true;
          """, completionHandler: nil)
        assertSnapshot(matching: webView, named: "desktop-team")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")

      }
    #endif
  }

  func testPricingLoggedIn() {
    let sessionCookie = """
    e78e522838eb96eb96253b60dca1f4afc46adfc6f2e8f6700f03b2b7df656c6d\
    bacd144a80672f96a0a077faf1b63f0de0ba20e2c6bfaaa321853ab5bfb20e8d\
    e3212f5827ef1f51d4542ee4e6920dbcc991459f02f1bdb778782d4a88a7abce
    """

    let request = URLRequest(url: URL(string: url(to: .pricing(nil, nil)))!)
      |> \.allHTTPHeaderFields .~ [
        "Cookie": "pf_session=\(sessionCookie)",
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1200))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")

      }
    #endif
  }
}
