import Either
import HttpPipeline
import Models
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class SubscriptionConfirmationTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.isRecording = true
  }

  func testPersonal_LoggedIn() {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
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

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1200))
        ]
      )
    }
    #endif
  }

  func testPersonal_LoggedIn_SwitchToMonthly() {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
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
        as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
        named: "desktop"
      )
    }
    #endif
  }

  func testPersonal_LoggedIn_SwitchToMonthly_RegionalDiscount() {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
          referralCode: nil,
          useRegionalDiscount: true
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
        as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
        named: "desktop"
      )
    }
    #endif
  }

  func testTeam_LoggedIn() {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

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

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1400))
        ]
      )
    }
    #endif
  }

  func testTeam_LoggedIn_WithDefaults() {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .team,
          billing: .some(.monthly),
          isOwnerTakingSeat: true,
          teammates: .some(["blob.jr@pointfree.co", "blob.sr@pointfree.co"]),
          referralCode: nil,
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
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1400))
        ]
      )
    }
    #endif
  }

  func testTeam_LoggedIn_WithDefaults_OwnerIsNotTakingSeat() {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .team,
          billing: .some(.monthly),
          isOwnerTakingSeat: false,
          teammates: .some(["blob.jr@pointfree.co", "blob.sr@pointfree.co"]),
          referralCode: nil,
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
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1400))
        ]
      )
    }
    #endif
  }

  func testTeam_LoggedIn_SwitchToMonthly() {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

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
        as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
        named: "desktop"
      )
    }
    #endif
  }

  func testTeam_LoggedIn_AddTeamMember() {
    var user = User.mock
    user.gitHubUserId = 1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

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
        as: .image(afterEvaluatingJavascript: "document.getElementById('add-team-member-button').click()"),
        named: "desktop"
      )
    }
    #endif
  }

  func testPersonal_LoggedIn_ActiveSubscriber() {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = const(pure(.mock))
    Current.database.fetchSubscriptionByOwnerId = const(pure(.mock))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
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

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut() {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
          referralCode: nil,
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
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1200))
        ]
      )
    }
    #endif
  }

  func testPersonal_LoggedIn_WithDiscount() {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(from: request(to: .discounts(code: "dead-beef", nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1200))
        ]
      )
    }
    #endif
  }

  func testTeam_LoggedIn_RemoveOwnerFromTeam() {
    var user = User.mock
    user.gitHubUserId = 1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

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
        as: .image(afterEvaluatingJavascript: "document.getElementById('remove-yourself-button').click()"),
        named: "desktop"
      )
    }
    #endif
  }

  func testPersonal_LoggedOut_ReferralCode() {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(.mock))
    Current.database.fetchUserByReferralCode = { code in pure(update(.mock) { $0.referralCode = code }) }
    Current.stripe.fetchSubscription = const(pure(.mock))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
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
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1200))
        ]
      )
    }
    #endif
  }

  func testPersonal_ReferralCodeAndRegionalDiscount() {
    Current.database.fetchUserByReferralCode = { code in pure(update(.mock) { $0.referralCode = code }) }

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
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
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1200))
        ]
      )
    }
    #endif
  }

  func testPersonal_LoggedOut_InactiveReferralCode() {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchUserByReferralCode = const(pure(.mock))
    Current.database.fetchSubscriptionByOwnerId = const(pure(.mock))
    Current.stripe.fetchSubscription = const(pure(.canceling))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
          referralCode: "cafed00d",
          useRegionalDiscount: false
        ),
        session: .loggedOut
      )
    )
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut_InvalidReferralCode() {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchUserByReferralCode = const(pure(nil))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
          referralCode: "cafed00d",
          useRegionalDiscount: false
        ),
        session: .loggedOut
      )
    )
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut_InvalidReferralLane() {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(.mock))
    Current.database.fetchUserByReferralCode = const(pure(.mock))
    Current.stripe.fetchSubscription = const(pure(.mock))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .team,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
          referralCode: "cafed00d",
          useRegionalDiscount: false
        ),
        session: .loggedOut
      )
    )
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedIn_PreviouslyReferred() {
    let user = update(User.nonSubscriber) {
      $0.referrerId = .init(rawValue: .mock)
    }
    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(.mock))
    Current.database.fetchUserByReferralCode = { code in pure(update(.mock) { $0.referralCode = code }) }
    Current.stripe.fetchSubscription = const(pure(.mock))

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil,
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

#if os(iOS) || os(macOS)
extension Snapshotting where Value == WKWebView, Format == NSImage {
  static func image(afterEvaluatingJavascript: String) -> Snapshotting {
    return Snapshotting<NSView, NSImage>.image.asyncPullback { (webView: WKWebView) -> Async<NSView> in
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
