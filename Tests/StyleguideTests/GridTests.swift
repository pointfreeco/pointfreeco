import Css
import CssTestSupport
import SnapshotTesting
import XCTest
@testable import Styleguide

class GridTests: XCTestCase {
  func testGrid() {
    assertSnapshot(matching: render(config: pretty, css: gridSystem), pathExtension: "css")
  }

  func testCompactGridSize() {
    XCTAssertGreaterThan(1500, render(config: compact, css: gridSystem).count)
  }
}

#if os(Linux)
  extension GridTests {
    static var allTests : [(String, GridTests -> () throws -> Void)] {
      return [
        ("testGrid", testGrid),
        ("testCompactGridSize", testCompactGridSize),
      ]
    }
  }
#endif

