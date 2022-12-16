import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

@MainActor
final class ApiTests: TestCase {
  override func setUp() {
    super.setUp()
    // SnapshotTesting.isRecording=true
  }

  func testEpisodes() async {
    let conn = await siteMiddleware(connection(from: request(to: .api(.episodes)))).performAsync()
    assertSnapshot(matching: conn, as: .conn)
  }

  func testEpisode() async {
    let conn = await siteMiddleware(connection(from: request(to: .api(.episode(1))))).performAsync()
    #if !os(Linux)
      // Can't run on Linux because of https://bugs.swift.org/browse/SR-11410
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testEpisode_NotFound() async {
    let conn = await siteMiddleware(connection(from: request(to: .api(.episode(424242)))))
      .performAsync()
    assertSnapshot(matching: conn, as: .conn)
  }
}
