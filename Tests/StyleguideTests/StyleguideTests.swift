import Css
import SnapshotTesting
import Styleguide
import XCTest

class StyleguideTests: XCTestCase {
  func testStyleguide() {
    assertSnapshot(matching: render(config: pretty, css: styleguide), record: true)
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
