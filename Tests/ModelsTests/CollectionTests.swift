import PointFreeTestSupport
import XCTest

@testable import Models

@MainActor
final class CollectionTests: TestCase {
  func testAllCollections() async throws {
    XCTAssertEqual(Episode.Collection.all, Episode.Collection.all)
  }
}
