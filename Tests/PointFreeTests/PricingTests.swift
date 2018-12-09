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
//    record=true
  }

  func testPricing() {
    let conn = connection(from: request(to: .pricing(nil, expand: nil)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1900))
      let html = String(decoding: siteMiddleware(conn).perform().data, as: UTF8.self)
      webView.loadHTMLString(html, baseURL: nil)
      assertSnapshot(matching: webView, as: .image, named: "desktop")

      webView.evaluateJavaScript(
        """
          document.getElementById('tab0').checked = false;
          document.getElementById('tab1').checked = true;
          var quantity = document.getElementsByName('pricing[quantity]')[0];
          quantity.value = 10;
          quantity.oninput();
          """, completionHandler: nil)
      assertSnapshot(matching: webView, as: .image, named: "desktop-team")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, as: .image, named: "mobile")

    }
    #endif
  }

  func testDiscount() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(
        to: Route.discounts(code: "swiftcount"),
        session: .loggedIn
      )
    )
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1900)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1900))
        ]
      )
    }
    #endif
  }

  func testInvalidDiscount() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.fetchCoupon .~ const(throwE(unit))
    )

    let conn = connection(
      from: request(
        to: Route.discounts(code: "swiftcount"),
        session: .loggedIn
      )
    )
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPricingLoggedIn_NonSubscriber() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .discounts(code: "swiftcount"), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1900)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1900))
        ]
      )
    }
    #endif
  }

  func testPricingLoggedIn_NonSubscriber_Expanded() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )
    let conn = connection(from: request(to: .pricing(nil, expand: true), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1900)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1900))
        ]
      )
    }
    #endif
  }

  func testPricingLoggedIn_Subscriber() {
    let conn = connection(from: request(to: .pricing(nil, expand: nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPricingLoggedIn_CanceledSubscriber() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(.canceled)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.canceled))
    )

    let conn = connection(from: request(to: .pricing(nil, expand: nil), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testPricingLoggedIn_PastDueSubscriber() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(.pastDue)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.pastDue))
    )

    let conn = connection(from: request(to: .pricing(nil, expand: nil), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
