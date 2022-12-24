import Either
import HttpPipeline
import ModelsTestSupport
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import XCTest

@testable import Models
@testable import PointFree

private let episodes: [Episode] = [
  .ep0_introduction,
  .ep1_functions,
  .ep2_sideEffects,
  .ep3_uikitStylingWithFunctions,
  .ep10_aTaleOfTwoFlatMaps,
  .ep22_aTourOfPointFree,
].map { update($0) { $0.image = "http://localhost:8080/images/\($0.sequence).jpg" } }

@MainActor
class PrivateRssTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    Current.episodes = { episodes }
    //SnapshotTesting.isRecording = true
  }

  func testFeed_Authenticated_Subscriber_Monthly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

    let conn = connection(
      from: request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_Subscriber_Yearly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.stripe.fetchSubscription = { _ in .individualYearly }

    let conn = connection(
      from: request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_NonSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.fetchSubscriptionById = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_InActiveSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef"

    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.fetchSubscriptionById = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_DeactivatedSubscriber() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    var subscription = Models.Subscription.mock
    subscription.deactivated = true

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.fetchSubscriptionById = { _ in subscription }

    let conn = connection(
      from: request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_BadSalt() async throws {
    Current.database.fetchUserByRssSalt = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_InvalidUserAgent() async throws {
    let user = Models.User.mock
    var feedRequestEventCreated = false

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.createFeedRequestEvent = { _, _, _ in
      feedRequestEventCreated = true
    }
    Current.envVars.rssUserAgentWatchlist = ["blob"]
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

    var req = request(
      to: .account(.rss(salt: "deadbeef")),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

    let conn = connection(from: req)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    XCTAssertTrue(feedRequestEventCreated)
  }

  func testFeed_ValidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.envVars.rssUserAgentWatchlist = ["blob"]
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

    var req = request(
      to: .account(.rss(salt: "deadbeef")),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Safari 1.0"

    let conn = connection(from: req)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_BadSalt_InvalidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    Current.database.fetchUserByRssSalt = { _ in throw unit }
    Current.database.updateUser = { _, _, _, _, _ in
      XCTFail("The user should not be updated.")
    }
    Current.envVars.rssUserAgentWatchlist = ["blob"]

    var req = request(
      to: .account(.rss(salt: "deadbeef")),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

    let conn = connection(from: req)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_Authenticated_Subscriber_Monthly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

    let conn = connection(
      from: request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_Authenticated_Subscriber_Yearly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.stripe.fetchSubscription = { _ in .individualYearly }

    let conn = connection(
      from: request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_Authenticated_NonSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef/cafebeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.fetchSubscriptionById = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_Authenticated_InActiveSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef/cafebeef"

    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.fetchSubscriptionById = { _ in subscription }

    let conn = connection(
      from: request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_Authenticated_DeactivatedSubscriber() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    var subscription = Models.Subscription.mock
    subscription.deactivated = true

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.fetchSubscriptionById = { _ in subscription }

    let conn = connection(
      from: request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_BadSalt() async throws {
    Current.database.fetchUserByRssSalt = { _ in throw unit }

    let conn = connection(
      from: request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
    )

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_InvalidUserAgent() async throws {
    let user = Models.User.mock
    var feedRequestEventCreated = false

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.database.createFeedRequestEvent = { _, _, _ in
      feedRequestEventCreated = true
    }
    Current.envVars.rssUserAgentWatchlist = ["blob"]
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

    var req = request(
      to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

    let conn = connection(from: req)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    XCTAssertTrue(feedRequestEventCreated)
  }

  func testLegacy_Feed_ValidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    Current.database.fetchUserByRssSalt = { _ in user }
    Current.envVars.rssUserAgentWatchlist = ["blob"]
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

    var req = request(
      to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Safari 1.0"

    let conn = connection(from: req)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLegacy_Feed_BadSalt_InvalidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    Current.database.fetchUserByRssSalt = { _ in throw unit }
    Current.database.updateUser = { _, _, _, _, _ in
      XCTFail("The user should not be updated.")
    }
    Current.envVars.rssUserAgentWatchlist = ["blob"]

    var req = request(
      to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

    let conn = connection(from: req)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

}
