import Either
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics

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
      var hook = request(to: .webhooks(.stripe(.subscription(.mock))))
      hook.addValue(
        "t=\(Int(AppEnvironment.current.date().timeIntervalSince1970)),v1=396c649804f91d7788c86f8571ea1e4ed7b768b71cb1e7a2ffceab312d35a3b5",
        forHTTPHeaderField: "Stripe-Signature"
      )

      let conn = connection(from: hook)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    #endif
  }

  func testInvalidHook() {
    var hook = request(to: .webhooks(.stripe(.subscription(.mock))))
    hook.addValue(
      "t=\(Int(AppEnvironment.current.date().timeIntervalSince1970)),v1=deadbeef",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }
}
