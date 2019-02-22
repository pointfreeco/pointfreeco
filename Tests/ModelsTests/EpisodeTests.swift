import XCTest
@testable import Models

final class EpisodeTests: XCTestCase {

  func testSlug() {
    var episode = Episode.mock
    episode.id = 42
    episode.sequence = 42
    episode.title = "Launching Point-Free"

    XCTAssertEqual("ep42-launching-point-free", episode.slug)
  }

  func testIsSubscriberOnly() {
    var episode = Episode.mock

    episode.permission = .free
    XCTAssertEqual(false, episode.isSubscriberOnly(currentDate: Date()))

    episode.permission = .subscriberOnly
    XCTAssertEqual(true, episode.isSubscriberOnly(currentDate: Date()))

    let start = Date(timeIntervalSince1970: 123456789)
    let end = start.addingTimeInterval(60*60*24*7)
    episode.permission = .freeDuring(start..<end)
    XCTAssertEqual(
      true,
      episode.isSubscriberOnly(currentDate: start.addingTimeInterval(-60))
    )
    XCTAssertEqual(
      false,
      episode.isSubscriberOnly(currentDate: start.addingTimeInterval(60))
    )
    XCTAssertEqual(
      false,
      episode.isSubscriberOnly(currentDate: end.addingTimeInterval(-60))
    )
    XCTAssertEqual(
      true,
      episode.isSubscriberOnly(currentDate: end.addingTimeInterval(60))
    )
  }

  func testFreeSince() {
    var episode = Episode.mock

    episode.permission = .free
    XCTAssertEqual(.some(episode.publishedAt), episode.freeSince)

    let start = Date(timeIntervalSince1970: 123456789)
    let end = start.addingTimeInterval(60*60*24*7)
    episode.permission = .freeDuring(start..<end)
    XCTAssertEqual(.some(start), episode.freeSince)

    episode.permission = .subscriberOnly
    XCTAssertEqual(nil, episode.freeSince)
  }
}
