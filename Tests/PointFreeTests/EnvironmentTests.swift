import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import PointFree

@MainActor
class EnvironmentTests: TestCase {
  func testDefault() async throws {
    let env = Environment()

    XCTAssertEqual(.encrypted, env.cookieTransform)
  }
}
