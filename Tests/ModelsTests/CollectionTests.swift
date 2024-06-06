import PointFreeTestSupport
import XCTest

@testable import Models

final class CollectionTests: TestCase {
  @MainActor
  func testAllCollections() async throws {
    XCTAssertEqual(Episode.Collection.all, Episode.Collection.all)
  }
}
