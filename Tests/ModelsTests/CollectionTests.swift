import XCTest
@testable import Models
import PointFreeTestSupport

final class CollectionTests: TestCase {
  func testAllCollections() {
    XCTAssertEqual(Episode.Collection.all, Episode.Collection.all)
  }
}
