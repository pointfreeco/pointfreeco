import Css
import CssTestSupport
import FunctionalCss
import SnapshotTesting
import XCTest

class StyleguideTests: XCTestCase {
  func testFunctionalCss() {
    assertSnapshot(matching: functionalCss, as: .css, named: "pretty")
    assertSnapshot(matching: functionalCss, as: .css(.compact), named: "mini")
  }
}
