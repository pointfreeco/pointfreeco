import ApplicativeRouter
import SnapshotTesting
import Optics
import Prelude
import XCTest
@testable import PointFree
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
    let freeEpisode = Episode.free
      |> \.title .~ "Free Episode"
      |> \.publishedAt .~ now.addingTimeInterval(-60 * 60 * 24 * 7)
    let recentlyFreeEpisode = Episode.subscriberOnly
      |> \.title .~ "Subscriber-Only Episode that is now free!"
      |> \.publishedAt .~ now.addingTimeInterval(-60 * 60 * 24 * 14)
      |> \.permission .~ Episode.Permission.freeDuring(now.addingTimeInterval(-60 * 60 * 24 * 2) ..< .distantFuture)

    update(
      &Current,
      \.episodes .~ unzurry([recentlyFreeEpisode, freeEpisode])
    )

    let conn = connection(from: request(to: .feed(.episodes)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
