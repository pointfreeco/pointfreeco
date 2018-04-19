import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import Optics
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

final class StripeHookTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testValidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.invoice(.mock))))
    hook.addValue(
      "t=\(Int(AppEnvironment.current.date().timeIntervalSince1970)),v1=3111e73ee4307d2ea48c59f85f18087a7a1f1f5e45bf8255be4e13d13102c83a",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
    #endif
  }

  func testStaleHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.invoice(.mock))))
    hook.addValue(
      "t=\(Int(AppEnvironment.current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=d5d9c018012292135f6471d14653b4e54fb0dacf7d528894bce016340343f529",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
    #endif
  }

  func testInvalidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.invoice(.mock))))
    hook.addValue(
      "t=\(Int(AppEnvironment.current.date().timeIntervalSince1970)),v1=deadbeef",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
    #endif
  }

  func testPastDueEmail() {
    let doc = pastDueEmailView.view(unit).first!

    assertSnapshot(matching: render(doc, config: pretty), pathExtension: "html")
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
