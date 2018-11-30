import Html
import HtmlCssSupport
import Optics
@testable import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Styleguide
import View
#if !os(Linux)
import WebKit
#endif
import XCTest

class MinimalNavViewTests: TestCase {
  func testNav_Html() {
    states.forEach { key, state in
      let doc = testDocView.view(state)

      assertSnapshot(matching: doc, as: .html, named: key)
    }
  }

  func testNav_Screenshots() {
    states.forEach { key, state in
      let doc = testDocView.view(state)

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

private let states: [(String, (NavStyle.MinimalStyle, Database.User?, SubscriberState, Route?))] = [
  ("dark_logged-out_no-route", (.dark, nil, .nonSubscriber, nil)),
  ("dark_logged-out_route", (.dark, nil, .nonSubscriber, .pricing(nil, expand: nil))),
  ("dark_logged-in_non-subscriber", (.dark, .mock, .nonSubscriber, nil)),
  ("dark_logged-in_inactive-subscriber", (.dark, .mock, .teammate(status: .canceled), nil)),
  ("dark_logged-in_active-subscriber", (.dark, .mock, .teammate(status: .active), nil)),

  ("light_logged-out", (.light, nil, .nonSubscriber, nil)),
  ("light_logged-in_non-subscriber", (.light, .mock, .nonSubscriber, nil)),
  ("light_logged-in_active-subscriber", (.light, .mock, .teammate(status: .active), nil)),
]

private let testDocView = View<(NavStyle.MinimalStyle, Database.User?, SubscriberState, Route?)> { style, currentUser, subscriberState, currentRoute in
  [
    doctype,
    html([
      head([
        Html.style(unsafe: renderedNormalizeCss),
        HtmlCssSupport.style(styleguide),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(minimalNavView.view((style, currentUser, subscriberState, currentRoute)))
      ])
  ]
}
