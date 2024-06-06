import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

final class ApiTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  @MainActor
  func testEpisodes() async throws {
    let conn = await siteMiddleware(connection(from: request(to: .api(.episodes))))
    await assertSnapshot(matching: conn, as: .conn)
  }

  @MainActor
  func testEpisode() async throws {
    let conn = await siteMiddleware(connection(from: request(to: .api(.episode(1)))))
    #if !os(Linux)
      // Can't run on Linux because of https://bugs.swift.org/browse/SR-11410
      await assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  @MainActor
  func testEpisode_NotFound() async throws {
    let conn = await siteMiddleware(connection(from: request(to: .api(.episode(424242)))))
    await assertSnapshot(matching: conn, as: .conn)
  }
}
