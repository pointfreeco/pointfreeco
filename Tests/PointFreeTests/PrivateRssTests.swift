import Either
import HttpPipeline
@testable import Models
import ModelsTestSupport
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import XCTest

class PrivateRssTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record = true
  }

  func testFeed_Authenticated_Subscriber_Monthly() {
    let user = Models.User.mock

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.episodes = unzurry([
      .ep0_introduction,
      .ep1_functions,
      .ep2_sideEffects,
      .ep3_uikitStylingWithFunctions,
      .ep10_aTaleOfTwoFlatMaps,
      .ep22_aTourOfPointFree,
    ])
    Current.stripe.fetchSubscription = const(pure(.individualMonthly))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)!

    let conn = connection(
      from: request(
        to: .account(.rss(userId: userId, rssSalt: rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_Subscriber_Yearly() {
    let user = Models.User.mock

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.episodes = unzurry([
      .ep0_introduction,
      .ep1_functions,
      .ep2_sideEffects,
      .ep3_uikitStylingWithFunctions,
      .ep10_aTaleOfTwoFlatMaps,
      .ep22_aTourOfPointFree,
    ])
    Current.stripe.fetchSubscription = const(pure(.individualYearly))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)!

    let conn = connection(
      from: request(
        to: .account(.rss(userId: userId, rssSalt: rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_NonSubscriber() {
    let user = Models.User.nonSubscriber

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.database.fetchSubscriptionById = const(throwE(unit))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)!

    let conn = connection(
      from: request(
        to: .account(.rss(userId: userId, rssSalt: rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_InActiveSubscriber() {
    let user = Models.User.nonSubscriber
    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.database.fetchSubscriptionById = const(pure(subscription))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)!

    let conn = connection(
      from: request(
        to: .account(.rss(userId: userId, rssSalt: rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_Authenticated_DeactivatedSubscriber() {
    let user = Models.User.mock
    var subscription = Models.Subscription.mock
    subscription.deactivated = true

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.database.fetchSubscriptionById = const(pure(subscription))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)!

    let conn = connection(
      from: request(
        to: .account(.rss(userId: userId, rssSalt: rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_BadSalt() {
    let user = Models.User.mock

    Current.database.fetchUserById = const(pure(.some(user)))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted("BAADBAAD-BAAD-BAAD-BAAD-BAADBAADBAAD", with: Current.envVars.appSecret)!

    let conn = connection(
      from: request(
        to: .account(.rss(userId: userId, rssSalt: rssSalt)),
        session: .loggedOut
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_InvalidUserAgent() {
    let user = Models.User.mock
    var feedRequestEventCreated = false

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.database.createFeedRequestEvent = { _, _, _ in
      feedRequestEventCreated = true
      return pure(unit)
    }
    Current.envVars.rssUserAgentWatchlist = ["blob"]
    Current.episodes = unzurry([
      .ep0_introduction,
      .ep1_functions,
      .ep2_sideEffects,
      .ep3_uikitStylingWithFunctions,
      .ep10_aTaleOfTwoFlatMaps,
      .ep22_aTourOfPointFree,
    ])
    Current.stripe.fetchSubscription = const(pure(.individualMonthly))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)!

    var req = request(
      to: .account(.rss(userId: userId, rssSalt: rssSalt)),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

    let conn = connection(from: req)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    XCTAssertTrue(feedRequestEventCreated)
  }

  func testFeed_ValidUserAgent() {
    let user = Models.User.mock

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.envVars.rssUserAgentWatchlist = ["blob"]
    Current.episodes = unzurry([
      .ep0_introduction,
      .ep1_functions,
      .ep2_sideEffects,
      .ep3_uikitStylingWithFunctions,
      .ep10_aTaleOfTwoFlatMaps,
      .ep22_aTourOfPointFree,
    ])
    Current.stripe.fetchSubscription = const(pure(.individualMonthly))

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)!

    var req = request(
      to: .account(.rss(userId: userId, rssSalt: rssSalt)),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Safari 1.0"

    let conn = connection(from: req)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testFeed_BadSalt_InvalidUserAgent() {
    let user = Models.User.mock

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.database.updateUser = { _, _, _, _, _, _ in
      XCTFail("The user should not be updated.")
      return pure(unit)
    }
    Current.envVars.rssUserAgentWatchlist = ["blob"]

    let userId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)!
    let rssSalt = Encrypted("BAADBAAD-BAAD-BAAD-BAAD-BAADBAADBAAD", with: Current.envVars.appSecret)!

    var req = request(
      to: .account(.rss(userId: userId, rssSalt: rssSalt)),
      session: .loggedOut
    )
    req.allHTTPHeaderFields?["User-Agent"] = "Blob 1.0 (https://www.blob.com)"

    let conn = connection(from: req)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

}
