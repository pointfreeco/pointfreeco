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
    let doc = testDocView.view(.mock)

    assertSnapshot(matching: doc.first!)

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 168))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }

  func testNav_LoggedIn() {
    let doc = testDocView.view(.mock)

    assertSnapshot(matching: doc.first!)

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 168))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }
}

private let testDocView = View<Database.User?> { currentUser in
  document([
    html([
      head([
        style(styleguide),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(darkNavView.view(currentUser))
      ])
    ])
}
