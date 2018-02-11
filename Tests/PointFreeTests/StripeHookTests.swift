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
        "t=\(Int(AppEnvironment.current.date().timeIntervalSince1970)),v1=369d17483762d03d2a55fe5facdfe8624e19959a5660c580b8857890281dcc0e",
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
        "t=\(Int(AppEnvironment.current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=f8f0e64e46cf1048071f070954258894d6cd9bf9f295fe6ad2874614d8a84114",
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
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView)

        webView.frame.size = .init(width: 400, height: 700)
        assertSnapshot(matching: webView)
      }
    #endif
  }
}
