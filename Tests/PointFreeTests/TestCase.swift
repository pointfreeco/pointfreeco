@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

class TestCase: XCTestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.push(
      env: .init(
        airtableStuff: mockCreateRow(result: .right(unit))
      )
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
