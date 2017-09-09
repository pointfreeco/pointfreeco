import XCTest
import Styleguide

class StyleguideTests: XCTestCase {
  func testExample() {
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

