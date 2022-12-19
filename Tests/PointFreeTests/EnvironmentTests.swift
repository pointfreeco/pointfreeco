import Dependencies
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import PointFree

class EnvironmentTests: TestCase {
  func testLive() {
    let env = Environment()
    DependencyValues.withValues {
      $0.context = .live
    } operation: {
      XCTAssertEqual(env.cookieTransform, .encrypted)
    }
  }
}
