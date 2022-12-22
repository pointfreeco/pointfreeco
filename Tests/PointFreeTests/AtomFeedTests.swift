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

class AtomFeedTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testAtomFeed() {
    let conn = connection(from: request(to: .feed(.atom)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testEpisodeFeed() {
    let conn = connection(from: request(to: .feed(.episodes)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testEpisodeFeed_WithRecentlyFreeEpisode() {
    let now = Date.mock
    var freeEpisode = Episode.free
    freeEpisode.title = "Free Episode"
    freeEpisode.publishedAt = now.addingTimeInterval(-60 * 60 * 24 * 7)
    var recentlyFreeEpisode = Episode.subscriberOnly
    recentlyFreeEpisode.title = "Subscriber-Only Episode that is now free!"
    recentlyFreeEpisode.publishedAt = now.addingTimeInterval(-60 * 60 * 24 * 14)
    recentlyFreeEpisode.permission = .freeDuring(
      now.addingTimeInterval(-60 * 60 * 24 * 2) ..< .distantFuture)

    DependencyValues.withTestValues {
      $0.episodes = { [recentlyFreeEpisode, freeEpisode] }
    } operation: {
      let conn = connection(from: request(to: .feed(.episodes)))
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }
}
