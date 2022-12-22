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

@MainActor
class SubscriptionConfirmationTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testPersonal_LoggedIn() async throws {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
        session: .loggedIn
      )
    )
    let result = conn |> siteMiddleware

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
    #endif
  }

  func testPersonal_LoggedIn_SwitchToMonthly() async throws {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

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
        let html = await String(decoding: result.performAsync().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        await assertSnapshot(
          matching: webView,
          as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
          named: "desktop"
        )
      }
    #endif
  }

  func testPersonal_LoggedIn_SwitchToMonthly_RegionalDiscount() async throws {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

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
        let html = await String(decoding: result.performAsync().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        await assertSnapshot(
          matching: webView,
          as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
          named: "desktop"
        )
      }
    #endif
  }

  func testTeam_LoggedIn() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(lane: .team, useRegionalDiscount: false),
        session: .loggedIn
      )
    )
    let result = conn |> siteMiddleware

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1400)),
          ]
        )
      }
    #endif
  }

  func testTeam_LoggedIn_WithDefaults() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

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

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1400)),
          ]
        )
      }
    #endif
  }

  func testTeam_LoggedIn_WithDefaults_OwnerIsNotTakingSeat() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

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

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1400)),
          ]
        )
      }
    #endif
  }

  func testTeam_LoggedIn_SwitchToMonthly() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

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
        let html = await String(decoding: result.performAsync().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        await assertSnapshot(
          matching: webView,
          as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
          named: "desktop"
        )
      }
    #endif
  }

  func testTeam_LoggedIn_AddTeamMember() async throws {
    var user = User.mock
    user.gitHubUserId = 1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

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
        let html = await String(decoding: result.performAsync().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        await assertSnapshot(
          matching: webView,
          as: .image(
            afterEvaluatingJavascript: "document.getElementById('add-team-member-button').click()"),
          named: "desktop"
        )
      }
    #endif
  }

  func testPersonal_LoggedIn_ActiveSubscriber() async throws {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = { _ in .mock }
    Current.database.fetchSubscriptionByOwnerId = { _ in .mock }

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
        session: .loggedIn
      )
    )
    let result = conn |> siteMiddleware

    await assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut() async throws {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
        session: .loggedOut
      )
    )
    let result = conn |> siteMiddleware

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
    #endif
  }

  func testPersonal_LoggedIn_WithDiscount() async throws {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

    let conn = connection(from: request(to: .discounts(code: "dead-beef", nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
    #endif
  }

  func testTeam_LoggedIn_RemoveOwnerFromTeam() async throws {
    var user = User.mock
    user.gitHubUserId = 1

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }

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
        let html = await String(decoding: result.performAsync().data, as: UTF8.self)
        webView.loadHTMLString(html, baseURL: nil)

        await assertSnapshot(
          matching: webView,
          as: .image(
            afterEvaluatingJavascript: "document.getElementById('remove-yourself-button').click()"),
          named: "desktop"
        )
      }
    #endif
  }

  func testPersonal_LoggedOut_ReferralCode() async throws {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in .mock }
    Current.database.fetchUserByReferralCode = { code in
      pure(update(.mock) { $0.referralCode = code })
    }
    Current.stripe.fetchSubscription = const(pure(.mock))

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

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
    #endif
  }

  func testPersonal_ReferralCodeAndRegionalDiscount() async throws {
    Current.database.fetchUserByReferralCode = { code in
      pure(update(.mock) { $0.referralCode = code })
    }

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

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
    #endif
  }

  func testPersonal_LoggedOut_InactiveReferralCode() async throws {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchUserByReferralCode = const(pure(.mock))
    Current.database.fetchSubscriptionByOwnerId = { _ in .mock }
    Current.stripe.fetchSubscription = const(pure(.canceling))

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

    await assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut_InvalidReferralCode() async throws {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchUserByReferralCode = const(pure(nil))

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

    await assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut_InvalidReferralLane() async throws {
    Current.database.fetchUserById = const(pure(nil))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in .mock }
    Current.database.fetchUserByReferralCode = const(pure(.mock))
    Current.stripe.fetchSubscription = const(pure(.mock))

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

    await assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedIn_PreviouslyReferred() async throws {
    let user = update(User.nonSubscriber) {
      $0.referrerId = .init(rawValue: .mock)
    }
    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in .mock }
    Current.database.fetchUserByReferralCode = { code in
      pure(update(.mock) { $0.referralCode = code })
    }
    Current.stripe.fetchSubscription = const(pure(.mock))

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

    await assertSnapshot(matching: result, as: .ioConn)
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
