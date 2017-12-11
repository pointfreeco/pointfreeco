@testable import PointFree
import SnapshotTesting
import XCTest

open class TestCase: XCTestCase {
  override open func setUp() {
    super.setUp()
    AppEnvironment.push(.mock)
  }

  override open func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
