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
      "t=\(Int(AppEnvironment.current.date().timeIntervalSince1970)),v1=a4f52b8407ddfaddcf61a3e3a874ee679424515a0a0c5894ee44f12503eb04ca",
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
      "t=\(Int(AppEnvironment.current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=5f255a9e30c548d47baa282a1f38bebcd33b7c7d5913cf87323c417d6f795083",
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
