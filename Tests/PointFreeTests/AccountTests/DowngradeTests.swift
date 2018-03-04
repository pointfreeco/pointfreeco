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

final class DowngradeTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testConfirmDowngrade() {
    AppEnvironment.with(
      \.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualYearly))
    ) {
      let conn = connection(from: request(to: .account(.subscription(.downgrade(.show))), session: .loggedIn))
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

  func testConfirmDowngradeLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.downgrade(.show)))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testConfirmDowngradeNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.downgrade(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmDowngradeInvalidSubscription() {
    AppEnvironment.with(
      \.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualMonthly))
    ) {
      let conn = connection(from: request(to: .account(.subscription(.downgrade(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmDowngradeCanceledSubscription() {
    let subscription = Stripe.Subscription.canceled
      |> \.plan .~ .individualYearly

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.subscription(.downgrade(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testDowngrade() {
    AppEnvironment.with(
      (\.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualYearly)))
        >>> (\.stripe.updateSubscription .~ { _, _, _, _ in pure(.mock |> \.plan .~ .individualMonthly) })
    ) {
      let conn = connection(
        from: request(to: .account(.subscription(.downgrade(.update))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testDowngradeLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.downgrade(.update)))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testDowngradeNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(
        from: request(to: .account(.subscription(.downgrade(.update))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testDowngradeInvalidSubscription() {
    AppEnvironment.with(
      \.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualMonthly))
    ) {
      let conn = connection(
        from: request(to: .account(.subscription(.downgrade(.update))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testDowngradeCanceledSubscription() {
    let subscription = Stripe.Subscription.canceled
      |> \.plan .~ .individualYearly

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.subscription(.downgrade(.update))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testDowngradeStripeError() {
    AppEnvironment.with(
      (\.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualYearly)))
        >>> (\.stripe.updateSubscription .~ { _, _, _, _ in throwE(unit as Error) })
    ) {
      let conn = connection(
        from: request(to: .account(.subscription(.downgrade(.update))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testDowngradeEmail() {
    let doc = downgradeEmailView.view((.mock, .mock)).first!

    assertSnapshot(matching: render(doc, config: pretty), pathExtension: "html")
    assertSnapshot(matching: plainText(for: doc))

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView)

        webView.frame.size = .init(width: 400, height: 700)
        assertSnapshot(matching: webView)
      }
    #endif
  }
}
