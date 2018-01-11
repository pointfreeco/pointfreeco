import Html
import HtmlCssSupport
import Optics
@testable import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Styleguide
#if !os(Linux)
  import WebKit
#endif
import XCTest

class MinimalNavViewTests: TestCase {
  func testNav_LoggedOut() {
    let states: [(String, (NavStyle.MinimalStyle, Database.User?, Stripe.Subscription.Status?, Route?))] = [
      ("dark_logged-out_no-route", (.dark, nil, nil, nil)),
      ("dark_logged-out_route", (.dark, nil, nil, .pricing(nil, nil))),
      ("dark_logged-in_non-subscriber", (.dark, .mock, nil, nil)),
      ("dark_logged-in_inactive-subscriber", (.dark, .mock, .canceled, nil)),
      ("dark_logged-in_active-subscriber", (.dark, .mock, .active, nil)),

      ("light_logged-out", (.light, nil, nil, nil)),
      ("light_logged-in_non-subscriber", (.light, .mock, nil, nil)),
      ("light_logged-in_active-subscriber", (.light, .mock, .active, nil)),
    ]

    states.forEach { key, state in
      let doc = testDocView.view(state)

      assertSnapshot(matching: doc.first!, named: key)

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 180))
          webView.loadHTMLString(render(doc), baseURL: nil)
          assertSnapshot(matching: webView, named: "\(key)_desktop")

          webView.frame.size.width = 500
          webView.frame.size.height = 140
          assertSnapshot(matching: webView, named: "\(key)_mobile")
        }
      #endif
    }
  }
}

private let testDocView = View<(NavStyle.MinimalStyle, Database.User?, Stripe.Subscription.Status?, Route?)> { style, currentUser, currentSubscriptionStatus, currentRoute in
  document([
    html([
      head([
        Html.style(renderedNormalizeCss),
        HtmlCssSupport.style(styleguide),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(minimalNavView.view((style, currentUser, currentSubscriptionStatus, currentRoute)))
      ])
    ])
}
