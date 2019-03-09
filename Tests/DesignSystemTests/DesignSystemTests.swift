import Css
import CssTestSupport
import DesignSystem
import SnapshotTesting
import XCTest

class StyleguideTests: XCTestCase {
  func testDesignSystem() {
    assertSnapshot(matching: designSystems, as: .css, named: "pretty")
    assertSnapshot(matching: designSystems, as: .css(.compact), named: "mini")
  }
}
