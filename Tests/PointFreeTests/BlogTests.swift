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

func withBasicAuth(_ req: URLRequest) -> URLRequest {
  var req = req
  req.allHTTPHeaderFields?["Authorization"] = "Basic " + Data("\(AppEnvironment.current.envVars.basicAuth.username):\(AppEnvironment.current.envVars.basicAuth.password)".utf8).base64EncodedString()
  return req
}

class BlogTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testBlogIndex() {
    let req = request(to: .blog(.index)) |> withBasicAuth
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1400))
      webView.loadHTMLString(String(data: result.data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testBlogIndex_Unauthed() {
    let req = request(to: .blog(.index)) |> withBasicAuth
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }

  func testBlogShow() {
    let req = request(to: .blog(.show(.right(1)))) |> withBasicAuth
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
      webView.loadHTMLString(String(data: result.data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testBlogShow_Unauthed() {
    let req = request(to: .blog(.show(.right(1)))) 
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }
}
