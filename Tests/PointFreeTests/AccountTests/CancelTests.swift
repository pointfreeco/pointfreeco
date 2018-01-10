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

final class CancelTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testConfirmCancel() {
    let conn = connection(from: request(to: .account(.subscription(.cancel(.show))), session: .loggedIn))
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

  func testConfirmCancelLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.cancel(.show)))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testConfirmCancelNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.cancel(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmCancelCancelingSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.canceling))) {
      let conn = connection(from: request(to: .account(.subscription(.cancel(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmCancelCanceledSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.canceled))) {
      let conn = connection(from: request(to: .account(.subscription(.cancel(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testCancel() {
    let conn = connection(from: request(to: .account(.subscription(.cancel(.update))), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testCancelLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.cancel(.update)))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testCancelNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.cancel(.update))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testCancelCancelingSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.canceling))) {
      let conn = connection(from: request(to: .account(.subscription(.cancel(.update))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testCancelCanceledSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.canceled))) {
      let conn = connection(from: request(to: .account(.subscription(.cancel(.update))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testCancelStripeFailure() {
    AppEnvironment.with(\.stripe.cancelSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.cancel(.update))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testReactivate() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.canceling))) {
      let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testReactivateLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.reactivate))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testReactivateNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testReactivateActiveSubscription() {
    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testReactivateCanceledSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.canceled))) {
      let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testReactivateStripeFailure() {
    AppEnvironment.with(\.stripe.updateSubscription .~ { _, _, _ in throwE(unit) }) {
      let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }
}
