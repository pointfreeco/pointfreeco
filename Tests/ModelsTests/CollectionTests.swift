import XCTest

@testable import Models

final class CollectionTests: XCTestCase {
  func testAllCollections() {
    XCTAssertEqual(Episode.Collection.all, Episode.Collection.all)
  }
}
