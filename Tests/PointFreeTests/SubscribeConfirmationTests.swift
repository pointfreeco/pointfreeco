import Either
import HttpPipeline
import Models
import Optics
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
//    record = true
  }

  func testPersonal_LoggedIn() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.personal, nil, nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.personal, nil, nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock |> \.gitHubUserId .~ -1)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.team, nil, nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock |> \.gitHubUserId .~ -1)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.team, nil, nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock |> \.gitHubUserId .~ -1)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.team, nil, nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock)),
      \.database.fetchSubscriptionById .~ const(pure(.mock)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.personal, nil, nil), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(nil)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.personal, nil, nil), session: .loggedOut))
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
        if webView.isLoading {
          delegate.didFinish = {
            webView.evaluateJavaScript(afterEvaluatingJavascript) { _, _ in
              _ = delegate
              callback(webView)
            }
          }
          webView.navigationDelegate = delegate
        } else {
          callback(webView)
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
