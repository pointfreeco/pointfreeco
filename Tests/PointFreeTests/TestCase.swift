import Prelude
@testable import PointFree
import PointFreeTestSupport
import SnapshotTesting
import XCTest

// sourcery: disableTests
class TestCase: XCTestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(const(.mock))
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
