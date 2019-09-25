import Models
import ModelsTestSupport
import SnapshotTesting
import HtmlUpgradeSnapshotTesting
import Views
import XCTest

class EpisodePageTests: XCTestCase {
  override func setUp() {
    super.setUp()
    //    record = true
  }

  func testEpisodePage() {
    let html = episodeView(
      episodePageData: EpisodePageData(
        permission: .loggedOut(isEpisodeSubscriberOnly: true),
        user: nil,
        subscriberState: SubscriberState(
          user: nil,
          subscriptionAndEnterpriseAccount: nil
        ),
        episode: .mock,
        previousEpisodes: [],
        date: { Date.init(timeIntervalSince1970: 1234567890) }
      )
    )

    assertSnapshot(matching: html, as: .html)
  }
}
