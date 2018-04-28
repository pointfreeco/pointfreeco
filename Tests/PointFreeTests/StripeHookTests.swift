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
    update(&Current, \.database .~ .mock)
  }

  func testValidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.invoice(.mock))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=499156b6abcf65d5c4a7c31f4e367d788b6112a030106c93aa2fc9fb1023473e",
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
      "t=\(Int(Current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=090637e9a79c21e220bbcc306207947dc9913e275bcf3ecaaa0c8a413fe71836",
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
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=deadbeef",
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
