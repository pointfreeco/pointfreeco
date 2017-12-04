import Html
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import Styleguide
import HtmlCssSupport
import SnapshotTesting
#if !os(Linux)
  import WebKit
#endif

class NavViewTests: TestCase {
  func testNav_LoggedOut() {
    let doc = testDocView.view(loggedOutRequestContext)

    assertSnapshot(matching: doc.first!)

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 80))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }

  func testNav_LoggedIn() {
    let doc = testDocView.view(loggedInRequestContext)

    assertSnapshot(matching: doc.first!)

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 80))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }
}

private let testDocView = View<RequestContext<Prelude.Unit>> { ctx in
  document([
    html([
      head([
        style(styleguide),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(navView.view(ctx))
      ])
    ])
}

private let loggedOutRequestContext = RequestContext(
  currentUser: nil,
  currentRequest: URLRequest(url: URL(string: "/")!),
  data: unit
)

private let loggedInRequestContext = RequestContext(
  currentUser: .mock,
  currentRequest: URLRequest(url: URL(string: "/")!),
  data: unit
)
