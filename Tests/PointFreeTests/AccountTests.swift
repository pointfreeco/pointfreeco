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

class AccountTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
  
  func testAccount() {
    let subscription = Stripe.Subscription.mock
      |> \.quantity .~ 5
      |> \.plan.id .~ .teamYearly
      |> \.plan.interval .~ .year

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: authedRequest(to: .account(.index)))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")
        }
      #endif
    }
  }

  func testAccountWithFlashNotice() {
    let flash = Flash(priority: .notice, message: "You’ve subscribed!")

    let conn = connection(from: authedRequest(to: .account(.index), session: .mock |> \.flash .~ flash))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    if #available(OSX 10.13, *) {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
  }

  func testAccountWithFlashWarning() {
      let flash = Flash(priority: .warning, message: "Your subscription is past-due!")

      let conn = connection(from: authedRequest(to: .account(.index), session: .mock |> \.flash .~ flash))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")
      }
  }

  func testAccountWithFlashError() {
      let flash = Flash(priority: .error, message: "An error has occurred!")

      let conn = connection(from: authedRequest(to: .account(.index), session: .mock |> \.flash .~ flash))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")
      }
  }

  func testAccountCancelingSubscription() {
    let subscription = Stripe.Subscription.canceling

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: authedRequest(to: .account(.index)))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")
        }
      #endif
    }
  }

  func testAccountCanceledSubscription() {
    let subscription = Stripe.Subscription.canceled

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: authedRequest(to: .account(.index)))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")
        }
      #endif
    }
  }
}
