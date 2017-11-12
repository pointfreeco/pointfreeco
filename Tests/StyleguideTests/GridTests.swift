import Css
import CssTestSupport
import SnapshotTesting
import XCTest
@testable import Styleguide

class GridTests: XCTestCase {
  func testGrid() {
    assertSnapshot(matching: render(config: pretty, css: grid), record: true)
  }
}

#if os(Linux)
  extension GridTests {
    static var allTests : [(String, GridTests -> () throws -> Void)] {
      return [
        ("testGrid", testGrid),
      ]
    }
  }
#endif
