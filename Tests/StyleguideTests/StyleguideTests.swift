import Css
import CssTestSupport
import PointFreeTestSupport
import SnapshotTesting
import Styleguide
import XCTest

class StyleguideTests: TestCase {
  func testStyleguide() {
    assertSnapshot(matching: styleguide, named: "pretty")
    assertSnapshot(of: .css(.compact), matching: styleguide, named: "mini")
  }

  func testDesignSystem() {
    assertSnapshot(matching: designSystems, named: "pretty")
    assertSnapshot(of: .css(.compact), matching: designSystems, named: "mini")
  }

  func testPointFreeStyles() {
    assertSnapshot(matching: pointFreeBaseStyles, named: "pretty")
    assertSnapshot(of: .css(.compact), matching: pointFreeBaseStyles, named: "mini")
  }
}
