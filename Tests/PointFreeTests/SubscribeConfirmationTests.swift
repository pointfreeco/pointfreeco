import Dependencies
import Either
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class SubscriptionConfirmationTests: TestCase {
  override func setUp() {
    super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testPersonal_LoggedIn() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(.mock))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
#endif
    }
  }

  func testPersonal_LoggedIn_SwitchToMonthly() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(.mock))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
        let html = String(decoding: result.perform().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
          matching: webView,
          as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
          named: "desktop"
        )
      }
#endif
    }
  }

  func testPersonal_LoggedIn_SwitchToMonthly_RegionalDiscount() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(.mock))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: true),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
        let html = String(decoding: result.perform().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
          matching: webView,
          as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
          named: "desktop"
        )
      }
#endif
    }
  }

  func testTeam_LoggedIn() {
    var user = User.mock
    user.gitHubUserId = -1

    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(user))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .team, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1400)),
          ]
        )
      }
#endif
    }
  }

  func testTeam_LoggedIn_WithDefaults() {
    var user = User.mock
    user.gitHubUserId = -1

    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(user))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .team,
            billing: .monthly,
            isOwnerTakingSeat: true,
            teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co"],
            useRegionalDiscount: false
          ),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1400)),
          ]
        )
      }
#endif
    }
  }

  func testTeam_LoggedIn_WithDefaults_OwnerIsNotTakingSeat() {
    var user = User.mock
    user.gitHubUserId = -1

    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(user))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .team,
            billing: .monthly,
            isOwnerTakingSeat: false,
            teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co"],
            useRegionalDiscount: false
          ),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1400)),
          ]
        )
      }
#endif
    }
  }

  func testTeam_LoggedIn_SwitchToMonthly() {
    var user = User.mock
    user.gitHubUserId = -1

    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(user))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .team, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
        let html = String(decoding: result.perform().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
          matching: webView,
          as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
          named: "desktop"
        )
      }
#endif
    }
  }

  func testTeam_LoggedIn_AddTeamMember() {
    var user = User.mock
    user.gitHubUserId = 1

    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(user))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .team,
            billing: nil,
            isOwnerTakingSeat: nil,
            teammates: nil,
            referralCode: nil,
            useRegionalDiscount: false
          ),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
        let html = String(decoding: result.perform().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
          matching: webView,
          as: .image(
            afterEvaluatingJavascript: "document.getElementById('add-team-member-button').click()"),
          named: "desktop"
        )
      }
#endif
    }
  }

  func testPersonal_LoggedIn_ActiveSubscriber() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(.mock))
      $0.database.fetchSubscriptionById = const(pure(.mock))
      $0.database.fetchSubscriptionByOwnerId = const(pure(.mock))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)
    }
  }

  func testPersonal_LoggedOut() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(nil))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedOut
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
#endif
    }
  }

  func testPersonal_LoggedIn_WithDiscount() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(.mock))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(from: request(to: .discounts(code: "dead-beef", nil), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
#endif
    }
  }

  func testTeam_LoggedIn_RemoveOwnerFromTeam() {
    var user = User.mock
    user.gitHubUserId = 1

    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(user))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .team, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
        let html = String(decoding: result.perform().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
          matching: webView,
          as: .image(
            afterEvaluatingJavascript: "document.getElementById('remove-yourself-button').click()"),
          named: "desktop"
        )
      }
#endif
    }
  }

  func testPersonal_LoggedOut_ReferralCode() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(nil))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(.mock))
      $0.database.fetchUserByReferralCode = { code in
        pure(update(.mock) { $0.referralCode = code })
      }
      $0.stripe.fetchSubscription = const(pure(.mock))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .personal,
            referralCode: "cafed00d",
            useRegionalDiscount: false
          ),
          session: .loggedOut
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
#endif
    }
  }

  func testPersonal_ReferralCodeAndRegionalDiscount() {
    DependencyValues.withTestValues {
      $0.database.fetchUserByReferralCode = { code in
        pure(update(.mock) { $0.referralCode = code })
      }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .personal,
            referralCode: "cafed00d",
            useRegionalDiscount: true
          ),
          session: .loggedIn
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
#endif
    }
  }

  func testPersonal_LoggedOut_InactiveReferralCode() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(nil))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchUserByReferralCode = const(pure(.mock))
      $0.database.fetchSubscriptionByOwnerId = const(pure(.mock))
      $0.stripe.fetchSubscription = const(pure(.canceling))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .personal,
            referralCode: "cafed00d",
            useRegionalDiscount: false
          ),
          session: .loggedOut
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)
    }
  }

  func testPersonal_LoggedOut_InvalidReferralCode() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(nil))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchUserByReferralCode = const(pure(nil))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .personal,
            referralCode: "cafed00d",
            useRegionalDiscount: false
          ),
          session: .loggedOut
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)
    }
  }

  func testPersonal_LoggedOut_InvalidReferralLane() {
    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(nil))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(.mock))
      $0.database.fetchUserByReferralCode = const(pure(.mock))
      $0.stripe.fetchSubscription = const(pure(.mock))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .team,
            referralCode: "cafed00d",
            useRegionalDiscount: false
          ),
          session: .loggedOut
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result, as: .ioConn)
    }
  }

  func testPersonal_LoggedIn_PreviouslyReferred() {
    let user = update(User.nonSubscriber) {
      $0.referrerId = .init(rawValue: .mock)
    }

    DependencyValues.withTestValues {
      $0.database.fetchUserById = const(pure(user))
      $0.database.fetchSubscriptionById = const(pure(nil))
      $0.database.fetchSubscriptionByOwnerId = const(pure(.mock))
      $0.database.fetchUserByReferralCode = { code in
        pure(update(.mock) { $0.referralCode = code })
      }
      $0.stripe.fetchSubscription = const(pure(.mock))
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(
            lane: .personal,
            referralCode: "cafed00d",
            useRegionalDiscount: false
          ),
          session: .loggedIn(as: user)
        )
      )
      let result = conn |> siteMiddleware
      
      assertSnapshot(matching: result, as: .ioConn)
    }
  }
}

#if os(iOS) || os(macOS)
  extension Snapshotting where Value == WKWebView, Format == NSImage {
    static func image(afterEvaluatingJavascript: String) -> Snapshotting {
      return Snapshotting<NSView, NSImage>.image.asyncPullback {
        (webView: WKWebView) -> Async<NSView> in
        return Async<NSView> { callback in
          let delegate = NavigationDelegate()

          let work = {
            webView.evaluateJavaScript(afterEvaluatingJavascript) { _, _ in
              _ = delegate
              callback(webView)
            }
          }

          if webView.isLoading {
            delegate.didFinish = work
            webView.navigationDelegate = delegate
          } else {
            work()
          }
        }
      }
    }
  }

  private final class NavigationDelegate: NSObject, WKNavigationDelegate {
    var didFinish: () -> Void

    init(didFinish: @escaping () -> Void = {}) {
      self.didFinish = didFinish
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      webView.evaluateJavaScript("document.readyState") { _, _ in
        self.didFinish()
      }
    }
  }
#endif
