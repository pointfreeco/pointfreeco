import Css
import CssTestSupport
import FunctionalCss
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@MainActor
class FunctionalCssTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.record = true
  }

  func testFunctionalCss() async throws {
    await assertSnapshot(matching: functionalCss, as: .css, named: "pretty")
    await assertSnapshot(matching: functionalCss, as: .css(.compact), named: "mini")
  }
}
