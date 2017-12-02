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
import Styleguide
import HtmlCssSupport
import SnapshotTesting

class NavViewTests: TestCase {
  func testNav_LoggedOut() {
    let doc = testDocView.view(loggedOutRequestContext)

    assertSnapshot(matching: doc.first!)

    if #available(OSX 10.13, *) {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 80))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
  }

  func testNav_LoggedIn() {
    let doc = testDocView.view(loggedInRequestContext)

    assertSnapshot(matching: doc.first!)

    if #available(OSX 10.13, *) {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 80))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
  }
}

private let testDocView = View<RequestContext<Prelude.Unit>> { context in
  document([
    html([
      head([
        style(styleguide),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(navView.view(context))
      ])
    ])
}

private let loggedOutRequestContext = RequestContext(
  currentUser: nil,
  currentRequest: URLRequest(url: URL(string: "/")!),
  data: unit
)

private let loggedInRequestContext = RequestContext(
  currentUser: User(
    email: "hello@pointfree.co",
    gitHubUserId: 1,
    gitHubAccessToken: "deadbeef",
    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
    name: "Blob",
    subscriptionId: nil
  ),
  currentRequest: URLRequest(url: URL(string: "/")!),
  data: unit
)
