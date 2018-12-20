import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest

class PrivateRssTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testFeed_Authenticated_Subscriber() {
    let user = Database.User.mock

    let episodes: [Episode] = (1...3).flatMap { idx -> [Episode] in
      [
        .subscriberOnly
          |> \.publishedAt .~ Current.date(),
        .free
          |> \.publishedAt .~ Current.date().addingTimeInterval(-2678400)
      ]
    }

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry(episodes)
    )

    let conn = connection(
      from: request(
        to: .account(.rss(userId: user.id, rssSalt: user.rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_NonSubscriber() {
    let user = Database.User.nonSubscriber

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.database.fetchSubscriptionByOwnerId .~ const(throwE(unit))
    )

    let conn = connection(
      from: request(
        to: .account(.rss(userId: user.id, rssSalt: user.rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_InActiveSubscriber() {
    let user = Database.User.nonSubscriber

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock |> \.stripeSubscriptionStatus .~ .pastDue))
    )

    let conn = connection(
      from: request(
        to: .account(.rss(userId: user.id, rssSalt: user.rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_BadSalt() {
    let user = Database.User.mock

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user)))
    )

    let conn = connection(
      from: request(
        to: .account(.rss(userId: user.id, rssSalt: .init(rawValue: UUID(uuidString: "baadbaad-baad-baad-baad-baadbaadbaad")!))),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
