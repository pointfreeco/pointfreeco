@testable import PointFree
import PointFreeMocks
import SnapshotTesting
import XCTest

class EnvironmentTests: TestCase {
  func testDefault() {
    let env = Environment()

    XCTAssertEqual(.encrypted, env.cookieTransform)
  }
}

