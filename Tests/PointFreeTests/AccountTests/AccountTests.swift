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

final class AccountTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(^\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testAccount() {
    AppEnvironment.with(const(.teamYearly)) {
      let conn = connection(from: request(to: .account(.index), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> ^\.flash .~ flash))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithFlashWarning() {
    let flash = Flash(priority: .warning, message: "Your subscription is past-due!")

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> ^\.flash .~ flash))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithFlashError() {
    let flash = Flash(priority: .error, message: "An error has occurred!")

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> ^\.flash .~ flash))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithPastDue() {
    let env: (Environment) -> Environment =
      (^\.database.fetchSubscriptionById .~ const(pure(.mock |> ^\.stripeSubscriptionStatus .~ .pastDue)))
        <> (^\.database.fetchSubscriptionByOwnerId .~ const(pure(.mock |> ^\.stripeSubscriptionStatus .~ .pastDue)))

    AppEnvironment.with(env) {
      let conn = connection(from: request(to: .account(.index), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testAccountCancelingSubscription() {
    let subscription = Stripe.Subscription.canceling

    AppEnvironment.with(^\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.index), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

    AppEnvironment.with(^\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.index), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testEpisodeCredits_1Credit_NoneChosen() {
    let user = Database.User.mock
      |> ^\.subscriptionId .~ nil
      |> ^\.episodeCreditCount .~ 1

    let env: (Environment) -> Environment =
      (^\.database.fetchUserById .~ const(pure(.some(user))))
        <> (^\.database.fetchEpisodeCredits .~ const(pure([])))
        <> (^\.database.fetchSubscriptionByOwnerId .~ const(pure(nil)))

    AppEnvironment.with(env) {
      let conn = connection(from: request(to: .account(.index), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1500))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testEpisodeCredits_1Credit_1Chosen() {
    let user = Database.User.mock
      |> ^\.subscriptionId .~ nil
      |> ^\.episodeCreditCount .~ 1

    let env: (Environment) -> Environment =
      (^\.database.fetchUserById .~ const(pure(.some(user))))
        <> (^\.database.fetchEpisodeCredits .~ const(pure([.mock])))
        <> (^\.database.fetchSubscriptionByOwnerId .~ const(pure(nil)))

    AppEnvironment.with(env) {
      let conn = connection(from: request(to: .account(.index), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1500))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }
}
