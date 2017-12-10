@testable import PointFree
import PointFreeTestSupport
import SnapshotTesting
import XCTest

// sourcery: disableTests
class TestCase: XCTestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(.mock)
//    record = true
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
  
