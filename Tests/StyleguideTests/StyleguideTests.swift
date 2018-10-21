import Css
import CssTestSupport
import PointFreeTestSupport
import SnapshotTesting
import Styleguide
import XCTest

class StyleguideTests: TestCase {
  func testStyleguide() {
    assertSnapshot(matching: styleguide, named: "pretty")
    assertSnapshot(matching: styleguide, with: .css(.compact), named: "mini")
  }

  func testDesignSystem() {
    assertSnapshot(matching: designSystems, named: "pretty")
    assertSnapshot(matching: designSystems, with: .css(.compact), named: "mini")
  }

  func testPointFreeStyles() {
    assertSnapshot(matching: pointFreeBaseStyles, named: "pretty")
    assertSnapshot(matching: pointFreeBaseStyles, with: .css(.compact), named: "mini")
  }
}
