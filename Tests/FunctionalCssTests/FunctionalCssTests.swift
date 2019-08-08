import Css
import CssTestSupport
import FunctionalCss
import SnapshotTesting
import XCTest

class FunctionalCssTests: SnapshotTestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testFunctionalCss() {
    assertSnapshot(matching: functionalCss, as: .css, named: "pretty")
    assertSnapshot(matching: functionalCss, as: .css(.compact), named: "mini")
  }
}
