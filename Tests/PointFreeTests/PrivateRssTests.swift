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

class PrivateRssTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  override func invokeTest() {
    DependencyValues.withTestValues {
      $0.episodes = { episodes }
    } operation: {
      super.invokeTest()
    }
  }

  func testFeed_Authenticated_Subscriber_Monthly() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.stripe.fetchSubscription = const(pure(.individualMonthly))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )
      
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_Subscriber_Yearly() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.stripe.fetchSubscription = const(pure(.individualYearly))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_NonSubscriber() {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef"

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.fetchSubscriptionById = const(throwE(unit))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_InActiveSubscriber() {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef"

    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.fetchSubscriptionById = const(pure(subscription))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_Authenticated_DeactivatedSubscriber() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    var subscription = Models.Subscription.mock
    subscription.deactivated = true

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.fetchSubscriptionById = const(pure(subscription))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_BadSalt() {
    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.none))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rss(salt: "deadbeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_InvalidUserAgent() {
    let user = Models.User.mock
    var feedRequestEventCreated = false

    DependencyValues.withTestValues {
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.createFeedRequestEvent = { _, _, _ in
        feedRequestEventCreated = true
        return pure(unit)
      }
      $0.stripe.fetchSubscription = const(pure(.individualMonthly))
    } operation: {
      var req = request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertTrue(feedRequestEventCreated)
    }
  }

  func testFeed_ValidUserAgent() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    DependencyValues.withTestValues {
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.stripe.fetchSubscription = const(pure(.individualMonthly))
    } operation: {
      var req = request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Safari 1.0"

      let conn = connection(from: req)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testFeed_BadSalt_InvalidUserAgent() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef"

    DependencyValues.withTestValues {
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.database.fetchUserByRssSalt = const(pure(.none))
      $0.database.updateUser = { _, _, _, _, _ in
        XCTFail("The user should not be updated.")
        return pure(unit)
      }
    } operation: {
      var req = request(
        to: .account(.rss(salt: "deadbeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_Subscriber_Monthly() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.stripe.fetchSubscription = const(pure(.individualMonthly))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_Subscriber_Yearly() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.stripe.fetchSubscription = const(pure(.individualYearly))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_NonSubscriber() {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef/cafebeef"

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.fetchSubscriptionById = const(throwE(unit))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_InActiveSubscriber() {
    var user = Models.User.nonSubscriber
    user.rssSalt = "deadbeef/cafebeef"

    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.fetchSubscriptionById = const(pure(subscription))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_Authenticated_DeactivatedSubscriber() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    var subscription = Models.Subscription.mock
    subscription.deactivated = true

    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.fetchSubscriptionById = const(pure(subscription))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_BadSalt() {
    DependencyValues.withTestValues {
      $0.database.fetchUserByRssSalt = const(pure(.none))
    } operation: {
      let conn = connection(
        from: request(
          to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
          session: .loggedOut
        )
      )

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_InvalidUserAgent() {
    let user = Models.User.mock
    var feedRequestEventCreated = false

    DependencyValues.withTestValues {
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.database.createFeedRequestEvent = { _, _, _ in
        feedRequestEventCreated = true
        return pure(unit)
      }
      $0.stripe.fetchSubscription = const(pure(.individualMonthly))
    } operation: {
      var req = request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertTrue(feedRequestEventCreated)
    }
  }

  func testLegacy_Feed_ValidUserAgent() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    DependencyValues.withTestValues {
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.database.fetchUserByRssSalt = const(pure(.some(user)))
      $0.stripe.fetchSubscription = const(pure(.individualMonthly))
    } operation: {
      var req = request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Safari 1.0"

      let conn = connection(from: req)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLegacy_Feed_BadSalt_InvalidUserAgent() {
    var user = Models.User.mock
    user.rssSalt = "deadbeef/cafebeef"

    DependencyValues.withTestValues {
      $0.envVars.rssUserAgentWatchlist = ["blob"]
      $0.database.fetchUserByRssSalt = const(pure(.none))
      $0.database.updateUser = { _, _, _, _, _ in
        XCTFail("The user should not be updated.")
        return pure(unit)
      }
    } operation: {
      var req = request(
        to: .account(.rssLegacy(secret1: "deadbeef", secret2: "cafebeef")),
        session: .loggedOut
      )
      req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

      let conn = connection(from: req)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }
}
