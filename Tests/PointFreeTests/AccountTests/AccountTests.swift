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
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testAccount() {
    Current = .teamYearly

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testTeam_OwnerIsNotSubscriber() {
    let currentUser = Database.User.nonSubscriber
    let subscription = Database.Subscription.mock
      |> (\Database.Subscription.userId) .~ currentUser.id

    Current = .teamYearly
      |> (\Environment.database.fetchUserById) .~ const(pure(.some(currentUser)))
      |> (\Environment.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([]))
      |> (\Environment.database.fetchSubscriptionById) .~ const(pure(.some(subscription)))

    let session = Session.loggedIn
      |> (\Session.userId) .~ currentUser.id
    let conn = connection(from: request(to: .account(.index), session: session))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccount_WithExtraInvoiceInfo() {
    Current = .teamYearly
      |> \.stripe.fetchSubscription .~ const(
        pure(
          .mock
            |> \.customer .~ .right(
              .mock
                |> \.metadata .~ ["extraInvoiceInfo": "VAT: 1234567890"]
          )
        )
    )

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithFlashNotice() {
    let flash = Flash(priority: .notice, message: "You’ve subscribed!")

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> \.flash .~ flash))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithFlashWarning() {
    let flash = Flash(priority: .warning, message: "Your subscription is past-due!")

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> \.flash .~ flash))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithFlashError() {
    let flash = Flash(priority: .error, message: "An error has occurred!")

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> \.flash .~ flash))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithPastDue() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(.mock |> \.stripeSubscriptionStatus .~ .pastDue)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock |> \.stripeSubscriptionStatus .~ .pastDue))
    )

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountCancelingSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceling)))

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountCanceledSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceled)))

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testEpisodeCredits_1Credit_NoneChosen() {
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    update(
      &Current,
      (\Environment.database.fetchUserById) .~ const(pure(.some(user))),
      \.database.fetchEpisodeCredits .~ const(pure([])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )
    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1500))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testEpisodeCredits_1Credit_1Chosen() {
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    update(
      &Current,
      (\Environment.database.fetchUserById) .~ const(pure(.some(user))),
      \.database.fetchEpisodeCredits .~ const(pure([.mock])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1500))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testAccountWithDiscount() {
    let subscription = Stripe.Subscription.mock
      |> \.discount .~ .mock
    Current = .teamYearly
      |> \.stripe.fetchSubscription .~ const(pure(subscription))

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

}
