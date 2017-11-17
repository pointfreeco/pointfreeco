import Css
import SnapshotTesting
import Styleguide
import XCTest

class StyleguideTests: XCTestCase {
  func testStyleguide() {
    assertSnapshot(matching: styleguide, record: true)
  }

  func test_SecretGrid() {
    assertSnapshot(matching: flexGridStyles, record: true)
  }

  func test_DesignSystem() {
    assertSnapshot(matching: designSystems, record: true)
  }
}

#if os(Linux)
extension StyleguideTests  {
  static var allTests : [(String, StyleguideTests -> () throws -> Void)] {
    return [
      ("testExample", testExample),
    ]
  }
}
#endif
