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

class BlogTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testBlogIndex() {
    let req = request(to: .blog(.index), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 2000))
      webView.loadHTMLString(String(decoding: result.data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testBlogIndex_WithLotsOfPosts() {
    let shortMock = BlogPost.mock |> \.contentBlocks .~ [BlogPost.mock.contentBlocks[1]]
    update(
      &Current,
      \.blogPosts .~ unzurry((1...6).map(const(shortMock)))
    )

    let req = request(to: .blog(.index), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 2400))
      webView.loadHTMLString(String(decoding: result.data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testBlogIndex_Unauthed() {
    let req = request(to: .blog(.index), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }

  func testBlogShow() {
    let req = request(to: .blog(.show(.mock)), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 2000))
      webView.loadHTMLString(String(decoding: result.data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testBlogShow_Unauthed() {
    let req = request(to: .blog(.show(.mock))) 
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }

  func testBlogAtomFeed() {
    let req = request(to: .blog(.feed(.atom)), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }

  func testBlogAtomFeed_Unauthed() {
    let req = request(to: .blog(.feed(.atom)))
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }
}
