import Either
import Html
import HtmlPlainTextPrint
import HtmlSnapshotTesting
import HttpPipeline
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree
@testable import Stripe

#if !os(Linux)
  import WebKit
#endif

final class CancelTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording=true
  }

  func testCancel() {
    var immediately: Bool?
    let cancelSubscription = Current.stripe.cancelSubscription
    Current.stripe.cancelSubscription = {
      immediately = $1
      return cancelSubscription($0, $1)
    }

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertEqual(false, immediately)
  }

  func testCancelPastDue() {
    Current.stripe.fetchSubscription = const(pure(update(.mock) { $0.status = .pastDue }))

    var immediately: Bool?
    let cancelSubscription = Current.stripe.cancelSubscription
    Current.stripe.cancelSubscription = {
      immediately = $1
      return cancelSubscription($0, $1)
    }

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertEqual(true, immediately)
  }

  func testCancelLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.cancel))))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelNoSubscription() {
    Current.stripe.fetchSubscription = const(throwE(unit))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelCancelingSubscription() {
    Current.stripe.fetchSubscription = const(pure(.canceling))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelCanceledSubscription() {
    Current.stripe.fetchSubscription = const(pure(.canceled))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelStripeFailure() {
    Current.stripe.cancelSubscription = { _, _ in throwE(unit) }

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
    Current.stripe.fetchSubscription = const(pure(.canceling))

    let conn = connection(
      from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.reactivate))))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateNoSubscription() {
    Current.stripe.fetchSubscription = const(throwE(unit))

    let conn = connection(
      from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateActiveSubscription() {
    let conn = connection(
      from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateCanceledSubscription() {
    Current.stripe.fetchSubscription = const(pure(.canceled))

    let conn = connection(
      from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateStripeFailure() {
    Current.stripe.updateSubscription = { _, _, _ in throwE(unit) }

    let conn = connection(
      from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

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
