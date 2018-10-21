import Either
import Html
import HtmlPlainTextPrint
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
    update(&Current, \.database .~ .mock)
  }

  func testCancel() {
    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testCancelLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.cancel))))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testCancelNoSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(throwE(unit)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testCancelCancelingSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceling)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testCancelCanceledSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceled)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testCancelStripeFailure() {
    update(&Current, \.stripe.cancelSubscription .~ const(throwE(unit)))

    let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testCancelEmail() {
    let doc = cancelEmailView.view((.mock, .mock))

    assertSnapshot(of: .html, matching: doc)
    assertSnapshot(matching: plainText(for: doc))

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView)

      webView.frame.size = .init(width: 400, height: 700)
      assertSnapshot(matching: webView)
    }
    #endif
  }

  func testReactivate() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceling)))

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testReactivateLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.reactivate))))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testReactivateNoSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(throwE(unit)))

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testReactivateActiveSubscription() {
    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testReactivateCanceledSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceled)))

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testReactivateStripeFailure() {
    update(&Current, \.stripe.updateSubscription .~ { _, _, _, _ in throwE(unit) })

    let conn = connection(from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }

  func testReactivateEmail() {
    let doc = reactivateEmailView.view((.mock, .mock))

    assertSnapshot(of: .html, matching: doc)
    assertSnapshot(matching: plainText(for: doc))

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView)

      webView.frame.size = .init(width: 400, height: 700)
      assertSnapshot(matching: webView)
    }
    #endif
  }
}
