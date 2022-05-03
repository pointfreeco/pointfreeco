import PointFreeTestSupport
import XCTest

@testable import Models

final class CollectionTests: TestCase {
  func testAllCollections() {
    XCTAssertEqual(Episode.Collection.all, Episode.Collection.all)
  }
}
