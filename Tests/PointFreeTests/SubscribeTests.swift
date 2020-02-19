import Either
import EmailAddress
@testable import GitHub
import HttpPipeline
import Models
import ModelsTestSupport
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
@testable import Stripe
import XCTest

final class SubscribeIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testCoupon_Individual() {
    var subscribeData = SubscribeData.individualMonthly
    subscribeData.coupon = "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn = connection(
      from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
    assertSnapshot(matching: subscription, as: .dump)
    #endif
  }

  func testCoupon_Team() {
    var subscribeData = SubscribeData.teamYearly(quantity: 4)
    subscribeData.coupon = "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn = connection(
      from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!
    XCTAssertNil(subscription)
  }

  func testHappyPath() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
    assertSnapshot(matching: subscription, as: .dump)
    #endif
  }

  func testHappyPath_Team() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let emails: [EmailAddress] = [
      "blob1@pointfree.co",
      "blob2@pointfree.co",
      "blob3@pointfree.co",
      "blob4@pointfree.co",
    ]

    var subscribeData = SubscribeData.teamYearly(quantity: 5)
    subscribeData.teammates = emails

    let req = request(
      to: .subscribe(.some(subscribeData)),
      session: session
    )
    let conn = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
    assertSnapshot(matching: subscription, as: .dump)
    #endif

    let invites = Current.database.fetchTeamInvites(user.id)
      .run
      .perform()
      .right!
    XCTAssertEqual(emails, invites.sorted { $0.email < $1.email }.map { $0.email })
  }

  func testHappyPath_Team_OwnerIsNotTakingSeat() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let emails: [EmailAddress] = [
      "blob1@pointfree.co",
      "blob2@pointfree.co",
      "blob3@pointfree.co",
      "blob4@pointfree.co",
      "blob5@pointfree.co",
    ]

    var subscribeData = SubscribeData.teamYearly(quantity: 5)
    subscribeData.teammates = emails
    subscribeData.isOwnerTakingSeat = false

    let req = request(
      to: .subscribe(.some(subscribeData)),
      session: session
    )
    let conn = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
    assertSnapshot(matching: subscription, as: .dump)
    #endif

    let invites = Current.database.fetchTeamInvites(user.id)
      .run
      .perform()
      .right!
    XCTAssertEqual(emails, invites.sorted { $0.email < $1.email }.map { $0.email })

    let freshUser = Current.database.fetchUserById(user.id)
      .run
      .perform()
      .right!!
    // Confirm that owner of subscription is not taking up a seat on the sub.
    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

}

final class SubscribeTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testNotLoggedIn_IndividualMonthly() {
    let conn = connection(from: request(to: .subscribe(.some(.individualMonthly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCouponFailure_Individual() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    var subscribeData = SubscribeData.individualMonthly
    subscribeData.coupon = "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn = connection(
      from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testNotLoggedIn_IndividualYearly() {
    let conn = connection(from: request(to: .subscribe(.some(.individualYearly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testNotLoggedIn_Team() {
    let conn = connection(from: request(to: .subscribe(.some(.teamYearly(quantity: 5)))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCurrentSubscribers() {
    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testInvalidQuantity() {
    #if !os(Linux)
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(to: .subscribe(.some(.teamYearly(quantity: 200))), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn, as: .conn, named: "too_high")

    let conn2 = connection(
      from: request(to: .subscribe(.some(.teamYearly(quantity: 0))), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn2, as: .conn, named: "too_low")
    #endif
  }

  func testCreateCustomerFailure() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createCustomer = { _, _, _, _ in throwE(unit as Error) }

    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateStripeSubscriptionFailure() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateStripeSubscriptionFailure_TeamAndMonthly() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      pricing: .init(billing: .monthly, quantity: 3),
      referralCode: nil,
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co"],
      token: "stripe-deadbeef"
    )

    let conn = connection(
      from: request(to: .subscribe(subscribeData), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateStripeSubscriptionFailure_TeamAndMonthly_TooManyEmails() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      pricing: .init(billing: .monthly, quantity: 3),
      referralCode: nil,
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co", "fake@pointfree.co"],
      token: "stripe-deadbeef"
    )

    let conn = connection(
      from: request(to: .subscribe(subscribeData), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateDatabaseSubscriptionFailure() {
    Current.database.createSubscription = { _, _, _ in throwE(unit as Error) }
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }
}
