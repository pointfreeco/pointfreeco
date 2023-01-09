import Dependencies
import HttpPipeline
import ModelsTestSupport
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import Models
@testable import PointFree

@MainActor
class AtomFeedTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testAtomFeed() async throws {
    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
    } operation: {
      let conn = connection(from: request(to: .feed(.atom)))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testEpisodeFeed() async throws {
    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
    } operation: {
      let conn = connection(from: request(to: .feed(.episodes)))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testEpisodeFeed_WithRecentlyFreeEpisode() async throws {
    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
    } operation: {
      let now = Date.mock
      var freeEpisode = Episode.free
      freeEpisode.title = "Free Episode"
      freeEpisode.publishedAt = now.addingTimeInterval(-60 * 60 * 24 * 7)
      var recentlyFreeEpisode = Episode.subscriberOnly
      recentlyFreeEpisode.title = "Subscriber-Only Episode that is now free!"
      recentlyFreeEpisode.publishedAt = now.addingTimeInterval(-60 * 60 * 24 * 14)
      recentlyFreeEpisode.permission = .freeDuring(
        now.addingTimeInterval(-60 * 60 * 24 * 2) ..< .distantFuture)

      await withDependencies {
        $0.episodes = { [recentlyFreeEpisode, freeEpisode] }
      } operation: {
        let conn = connection(from: request(to: .feed(.episodes)))
        await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      }
    }
  }
}
