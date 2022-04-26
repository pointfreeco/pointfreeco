import Html
import HtmlCssSupport
import Models
import ModelsTestSupport
@testable import PointFree
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Styleguide
import Views
#if !os(Linux)
import WebKit
#endif
import XCTest

class MinimalNavViewTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record=true
  }

  func testNav_Html() {
    states.forEach { key, state in
      let doc = testDocView(state)

      assertSnapshot(matching: doc, as: .html, named: key)
    }
  }

  func testNav_Screenshots() {
    states.forEach { key, state in
      let doc = testDocView(state)

      #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 180))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView, as: .image, named: "\(key)_desktop")

        webView.frame.size.width = 500
        webView.frame.size.height = 140
        assertSnapshot(matching: webView, as: .image, named: "\(key)_mobile")
      }
      #endif
    }
  }
}

private let states: [(String, (NavStyle.MinimalStyle, Models.User?, SubscriberState, SiteRoute?))] = [
  ("dark_logged-out_no-route", (.dark, nil, .nonSubscriber, nil)),
  ("dark_logged-out_route", (.dark, nil, .nonSubscriber, .pricingLanding)),
  ("dark_logged-in_non-subscriber", (.dark, .mock, .nonSubscriber, nil)),
  ("dark_logged-in_inactive-subscriber", (.dark, .mock, .teammate(status: .canceled, enterpriseAccount: nil, deactivated: false), nil)),
  ("dark_logged-in_active-subscriber", (.dark, .mock, .teammate(status: .active, enterpriseAccount: nil, deactivated: false), nil)),

  ("light_logged-out", (.light, nil, .nonSubscriber, nil)),
  ("light_logged-in_non-subscriber", (.light, .mock, .nonSubscriber, nil)),
  ("light_logged-in_active-subscriber", (.light, .mock, .teammate(status: .active, enterpriseAccount: nil, deactivated: false), nil)),
]

private func testDocView(
  _ data: (
  style: NavStyle.MinimalStyle,
  currentUser: Models.User?,
  subscriberState: SubscriberState,
  currentRoute: SiteRoute?
  )
) -> Node {
  return [
    .doctype,
    .html(
      .head(
        .style(safe: renderedNormalizeCss),
        .style(styleguide),
        .meta(viewport: .width(.deviceWidth), .initialScale(1))
      ),
      .body(
        minimalNavView(
          style: data.style,
          currentUser: data.currentUser,
          subscriberState: data.subscriberState,
          currentRoute: data.currentRoute
        )
      )
    )
  ]
}
