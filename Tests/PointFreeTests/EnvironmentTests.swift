import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import PointFree

class EnvironmentTests: TestCase {
  func testDefault() {
    let env = Environment()

    XCTAssertEqual(.encrypted, env.cookieTransform)
  }
}
