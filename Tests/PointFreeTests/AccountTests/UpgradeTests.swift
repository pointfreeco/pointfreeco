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

final class UpgradeTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testConfirmUpgrade() {
    AppEnvironment.with(
      \.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualMonthly))
    ) {
      let conn = connection(from: request(to: .account(.subscription(.upgrade(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")
        }
      #endif
    }
  }

  func testConfirmUpgradeLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.upgrade(.show)))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testConfirmUpgradeNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.upgrade(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmUpgradeInvalidSubscription() {
    AppEnvironment.with(
      \.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualYearly))
    ) {
      let conn = connection(from: request(to: .account(.subscription(.upgrade(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmUpgradeCanceledSubscription() {
    let subscription = Stripe.Subscription.canceled
      |> \.plan .~ .individualMonthly

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.subscription(.upgrade(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testUpgrade() {
    AppEnvironment.with(
      (\.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualMonthly)))
        >>> (\.stripe.updateSubscription .~ { _, _, _ in pure(.mock |> \.plan .~ .individualYearly) })
    ) {
      let conn = connection(
        from: request(to: .account(.subscription(.upgrade(.update))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testUpgradeLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.upgrade(.update)))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testUpgradeNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(
        from: request(to: .account(.subscription(.upgrade(.update))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testUpgradeInvalidSubscription() {
    AppEnvironment.with(
      \.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualYearly))
    ) {
      let conn = connection(
        from: request(to: .account(.subscription(.upgrade(.update))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testUpgradeCanceledSubscription() {
    let subscription = Stripe.Subscription.canceled
      |> \.plan .~ .individualMonthly

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.subscription(.upgrade(.update))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }
}
