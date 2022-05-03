import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

final class ApiTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording=true
  }

  func testEpisodes() {
    let conn =
      connection(from: request(to: .api(.episodes)))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn, as: .conn)
  }

  func testEpisode() {
    let conn =
      connection(from: request(to: .api(.episode(1))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      // Can't run on Linux because of https://bugs.swift.org/browse/SR-11410
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testEpisode_NotFound() {
    let conn =
      connection(from: request(to: .api(.episode(424242))))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn, as: .conn)
  }
}
