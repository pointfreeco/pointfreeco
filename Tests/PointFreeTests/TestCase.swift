@testable import PointFree
import PointFreeTestSupport
import XCTest

// sourcery: disableTests
class TestCase: XCTestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(.mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
