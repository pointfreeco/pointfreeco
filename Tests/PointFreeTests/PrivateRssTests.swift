import Dependencies
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
    //SnapshotTesting.isRecording = true
  }

  override func invokeTest() {
    withDependencies {
      $0.episodes = { episodes }
    } operation: {
      super.invokeTest()
    }
  }

  func testFeed_Authenticated_Subscriber_Monthly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_Subscriber_Yearly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.stripe.fetchSubscription = { _ in .individualYearly }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_Subscriber_Yearly_StripeDown() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.stripe.fetchSubscription = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_NonSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_InActiveSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef"

    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_DeactivatedSubscriber() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    var subscription = Models.Subscription.mock
    subscription.deactivated = true

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.fetchSubscriptionById = { _ in subscription }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_BadSalt() async throws {
    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_InvalidUserAgent() async throws {
    let user = Models.User.mock
    var feedRequestEventCreated = false

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.createFeedRequestEvent = { _, _, _ in feedRequestEventCreated = true }
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
    } operation: {
      var req = request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertTrue(feedRequestEventCreated)
    }
  }

  func testFeed_ValidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
    } operation: {
      var req = request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Safari 1.0"

      let conn = connection(from: req)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_BadSalt_InvalidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in throw unit }
      $0.database.updateUser = { _, _, _, _, _ in XCTFail("The user should not be updated.") }
      $0.envVars.rssUserAgentWatchlist = ["blob"]
    } operation: {
      var req = request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_Subscriber_Monthly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_Subscriber_Yearly() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.stripe.fetchSubscription = { _ in .individualYearly }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_NonSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef/cafebeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_InActiveSubscriber() async throws {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef/cafebeef"

    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.fetchSubscriptionById = { _ in subscription }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_DeactivatedSubscriber() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    var subscription = Models.Subscription.mock
    subscription.deactivated = true

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.fetchSubscriptionById = { _ in subscription }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_BadSalt() async throws {
    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_InvalidUserAgent() async throws {
    let user = Models.User.mock
    var feedRequestEventCreated = false

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.database.createFeedRequestEvent = { _, _, _ in
        feedRequestEventCreated = true
      }
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
    } operation: {
      var req = request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertTrue(feedRequestEventCreated)
    }
  }

  func testLegacy_Feed_ValidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in user }
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
    } operation: {
      var req = request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Safari 1.0"

      let conn = connection(from: req)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_BadSalt_InvalidUserAgent() async throws {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    await withDependencies {
      $0.calendar = .init(identifier: .gregorian)
      $0.database.fetchUserByRssSalt = { _ in throw unit }
      $0.database.updateUser = { _, _, _, _, _ in
        XCTFail("The user should not be updated.")
      }
      $0.envVars.rssUserAgentWatchlist = ["blob"]
    } operation: {
      var req = request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }
}
