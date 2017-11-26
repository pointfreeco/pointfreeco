import Css
import SnapshotTesting
import Styleguide
import XCTest

class StyleguideTests: XCTestCase {
  func testStyleguide() {
    assertSnapshot(matching: render(config: pretty, css: styleguide), pathExtension: "css")
  }

  func test_DesignSystem() {
    assertSnapshot(matching: render(config: pretty, css: designSystems), pathExtension: "css")
  }
}
