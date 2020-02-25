import ApplicativeRouter
import SnapshotTesting
@testable import Models
import ModelsTestSupport
import Prelude
import XCTest
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import HttpPipeline

class AtomFeedTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
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
    let now = Current.date()
    var freeEpisode = Episode.free
    freeEpisode.title = "Free Episode"
    freeEpisode.publishedAt = now.addingTimeInterval(-60 * 60 * 24 * 7)
    var recentlyFreeEpisode = Episode.subscriberOnly
    recentlyFreeEpisode.title = "Subscriber-Only Episode that is now free!"
    recentlyFreeEpisode.publishedAt = now.addingTimeInterval(-60 * 60 * 24 * 14)
    recentlyFreeEpisode.permission = .freeDuring(now.addingTimeInterval(-60 * 60 * 24 * 2) ..< .distantFuture)

    Current.episodes = unzurry([recentlyFreeEpisode, freeEpisode])

    let conn = connection(from: request(to: .feed(.episodes)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
