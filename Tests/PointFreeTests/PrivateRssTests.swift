import Either
import HttpPipeline
import Models
import ModelsTestSupport
import Optics
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
//    record = true
  }

  func testFeed_Authenticated_Subscriber_Monthly() {
    let user = Models.User.mock

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry([introduction, ep1, ep2, ep3, ep10, ep22]),
      \.stripe.fetchSubscription .~ const(pure(.individualMonthly))
    )

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

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry([introduction, ep1, ep2, ep3, ep10, ep22]),
      \.stripe.fetchSubscription .~ const(pure(.individualYearly))
    )

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

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.database.fetchSubscriptionByOwnerId .~ const(throwE(unit))
    )

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

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock |> \.stripeSubscriptionStatus .~ .pastDue))
    )

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

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user)))
    )

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

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.envVars.rssUserAgentWatchlist = ["blob"]
    Current.episodes = unzurry([introduction, ep1, ep2, ep3, ep10, ep22])
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
  }

  func testFeed_BadSalt_InvalidUserAgent() {
    let user = Models.User.mock

    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.envVars.rssUserAgentWatchlist .~ ["blob"]
    )
    
    Current.database.updateUser = { _, _, _, _, _, _ in
      XCTFail("The user should not be updated.")
      return pure(unit)
    }

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
