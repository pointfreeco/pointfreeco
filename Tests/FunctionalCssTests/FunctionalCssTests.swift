import Css
import CssTestSupport
import FunctionalCss
import PointFreeTestSupport
import SnapshotTesting
import XCTest

class FunctionalCssTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record = true
  }

  func testFunctionalCss() {
    assertSnapshot(matching: functionalCss, as: .css, named: "pretty")
    assertSnapshot(matching: functionalCss, as: .css(.compact), named: "mini")
  }
}
