import Dependencies
import Either
import Html
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
    await withDependencies {
      $0.database.fetchUserById = { _ in .mock }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testPersonal_LoggedIn_SwitchToMonthly() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in .mock }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.renderHtml = { Html.render($0) }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = await _siteMiddleware(conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
          let html = await String(decoding: siteMiddleware(conn).performAsync().data, as: UTF8.self)
          webView.loadHTMLString(html, baseURL: nil)

          await assertSnapshot(
            matching: webView,
            as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
            named: "desktop"
          )
        }
      #endif
    }
  }

  func testPersonal_LoggedIn_SwitchToMonthly_RegionalDiscount() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in .mock }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.renderHtml = { Html.render($0) }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: true),
          session: .loggedIn
        )
      )
      let result = await _siteMiddleware(conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
          let html = await String(decoding: siteMiddleware(conn).performAsync().data, as: UTF8.self)
          webView.loadHTMLString(html, baseURL: nil)

          await assertSnapshot(
            matching: webView,
            as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
            named: "desktop"
          )
        }
      #endif
    }
  }

  func testTeam_LoggedIn() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .team, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testTeam_LoggedIn_WithDefaults() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testTeam_LoggedIn_WithDefaults_OwnerIsNotTakingSeat() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testTeam_LoggedIn_SwitchToMonthly() async throws {
    var user = User.mock
    user.gitHubUserId = -1

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.renderHtml = { Html.render($0) }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .team, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = await _siteMiddleware(conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
          let html = await String(decoding: siteMiddleware(conn).performAsync().data, as: UTF8.self)
          webView.loadHTMLString(html, baseURL: nil)

          await assertSnapshot(
            matching: webView,
            as: .image(afterEvaluatingJavascript: "document.getElementById('monthly').click()"),
            named: "desktop"
          )
        }
      #endif
    }
  }

  func testTeam_LoggedIn_AddTeamMember() async throws {
    var user = User.mock
    user.gitHubUserId = 1

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.renderHtml = { Html.render($0) }
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
      let result = await _siteMiddleware(conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
          let html = await String(decoding: siteMiddleware(conn).performAsync().data, as: UTF8.self)
          webView.loadHTMLString(html, baseURL: nil)

          await assertSnapshot(
            matching: webView,
            as: .image(
              afterEvaluatingJavascript: "document.getElementById('add-team-member-button').click()"
            ),
            named: "desktop"
          )
        }
      #endif
    }
  }

  func testPersonal_LoggedIn_ActiveSubscriber() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in .mock }
      $0.database.fetchSubscriptionById = { _ in .mock }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)
    }
  }

  func testPersonal_LoggedOut() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: false),
          session: .loggedOut
        )
      )
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testPersonal_LoggedIn_WithDiscount() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in .mock }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(to: .discounts(code: "dead-beef", nil), session: .loggedIn))
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testTeam_LoggedIn_RemoveOwnerFromTeam() async throws {
    var user = User.mock
    user.gitHubUserId = 1

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.renderHtml = { Html.render($0) }
    } operation: {
      let conn = connection(
        from: request(
          to: .subscribeConfirmation(lane: .team, useRegionalDiscount: false),
          session: .loggedIn
        )
      )
      let result = await _siteMiddleware(conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
          let html = await String(decoding: siteMiddleware(conn).performAsync().data, as: UTF8.self)
          webView.loadHTMLString(html, baseURL: nil)

          await assertSnapshot(
            matching: webView,
            as: .image(
              afterEvaluatingJavascript: "document.getElementById('remove-yourself-button').click()"
            ),
            named: "desktop"
          )
        }
      #endif
    }
  }

  func testPersonal_LoggedOut_ReferralCode() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
      $0.database.fetchUserByReferralCode = { code in update(.mock) { $0.referralCode = code } }
      $0.stripe.fetchSubscription = { _ in .mock }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testPersonal_ReferralCodeAndRegionalDiscount() async throws {
    await withDependencies {
      $0.database.fetchUserByReferralCode = { code in update(.mock) { $0.referralCode = code } }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

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
  }

  func testPersonal_LoggedOut_InactiveReferralCode() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchUserByReferralCode = { _ in .mock }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
      $0.stripe.fetchSubscription = { _ in .canceling }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)
    }
  }

  func testPersonal_LoggedOut_InvalidReferralCode() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchUserByReferralCode = { _ in throw unit }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)
    }
  }

  func testPersonal_LoggedOut_InvalidReferralLane() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
      $0.database.fetchUserByReferralCode = { _ in .mock }
      $0.stripe.fetchSubscription = { _ in .mock }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)
    }
  }

  func testPersonal_LoggedIn_PreviouslyReferred() async throws {
    let user = update(User.nonSubscriber) {
      $0.referrerId = .init(rawValue: .mock)
    }

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
      $0.database.fetchUserByReferralCode = { code in update(.mock) { $0.referralCode = code } }
      $0.stripe.fetchSubscription = { _ in .mock }
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
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)
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
