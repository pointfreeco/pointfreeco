import Either
import Html
import HtmlPlainTextPrint
import HtmlSnapshotTesting
import HttpPipeline
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
@testable import Stripe
#if !os(Linux)
import WebKit
#endif
import XCTest

final class CancelTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record=true
  }

  func testCancel() {
    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.cancel))))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelNoSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(throwE(unit)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelCancelingSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceling)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelCanceledSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceled)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelStripeFailure() {
    update(&Current, \.stripe.cancelSubscription .~ const(throwE(unit)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelEmail() {
    let doc = cancelEmailView((.mock, .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 700)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testReactivate() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceling)))

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.reactivate))))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateNoSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(throwE(unit)))

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateActiveSubscription() {
    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateCanceledSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceled)))

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateStripeFailure() {
    update(&Current, \.stripe.updateSubscription .~ { _, _, _, _ in throwE(unit) })

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateEmail() {
    let doc = reactivateEmailView((.mock, .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 700)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }
}
