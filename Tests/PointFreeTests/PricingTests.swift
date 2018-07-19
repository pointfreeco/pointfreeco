import Either
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
    update(&Current, \.database .~ .mock)
  }

  func testPricing() {
    let conn = connection(from: request(to: .pricing(nil, expand: nil)))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1900))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.evaluateJavaScript(
        """
          document.getElementById('tab0').checked = false;
          document.getElementById('tab1').checked = true;
          var quantity = document.getElementsByName('pricing[quantity]')[0];
          quantity.value = 10;
          quantity.onchange();
          """, completionHandler: nil)
      assertSnapshot(matching: webView, named: "desktop-team")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")

    }
    #endif
  }

  func testPricingLoggedIn_NonSubscriber() {
    update(
      &Current, 
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )
    
    let conn = connection(from: request(to: .pricing(nil, expand: nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1900))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")

    }
    #endif
  }

  func testPricingLoggedIn_Subscriber() {
    let conn = connection(from: request(to: .pricing(nil, expand: nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testPricingLoggedIn_CanceledSubscriber() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(.canceled)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.canceled))
    )

    let conn = connection(from: request(to: .pricing(nil, expand: nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testPricingLoggedIn_PastDueSubscriber() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(.pastDue)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.pastDue))
    )

    let conn = connection(from: request(to: .pricing(nil, expand: nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }
}
