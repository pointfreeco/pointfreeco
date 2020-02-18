import Either
import EmailAddress
@testable import GitHub
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
@testable import Stripe
import XCTest

final class SubscribeIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testCoupon_Individual() {
    let subscribeData = SubscribeData.individualMonthly
      |> \.coupon .~ "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    let session = Session.loggedIn |> \.user .~ .standard(user.id)

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
    let subscribeData = SubscribeData.teamYearly(quantity: 4)
      |> \.coupon .~ "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    let session = Session.loggedIn |> \.user .~ .standard(user.id)

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
    let session = Session.loggedIn |> \.user .~ .standard(user.id)

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
    let session = Session.loggedIn |> \.user .~ .standard(user.id)

    let emails: [EmailAddress] = [
      "blob1@pointfree.co",
      "blob2@pointfree.co",
      "blob3@pointfree.co",
      "blob4@pointfree.co",
    ]

    let req = request(
      to: .subscribe(
        .some(
          .teamYearly(quantity: 5)
            |> \.teammates .~ emails
        )
      ),
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
    let session = Session.loggedIn |> \.user .~ .standard(user.id)

    let emails: [EmailAddress] = [
      "blob1@pointfree.co",
      "blob2@pointfree.co",
      "blob3@pointfree.co",
      "blob4@pointfree.co",
      "blob5@pointfree.co",
    ]

    let req = request(
      to: .subscribe(
        .some(
          .teamYearly(quantity: 5)
            |> \.teammates .~ emails
            |> \.isOwnerTakingSeat .~ false
        )
      ),
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

    let subscribeData = SubscribeData.individualMonthly
      |> \.coupon .~ "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    let session = Session.loggedIn |> \.user .~ .standard(user.id)

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
    update(&Current, \.database .~ .mock)
    let conn = connection(from: request(to: .subscribe(.some(.individualYearly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testNotLoggedIn_Team() {
    update(&Current, \.database .~ .mock)
    let conn = connection(from: request(to: .subscribe(.some(.teamYearly(quantity: 5)))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCurrentSubscribers() {
    update(&Current, \.database .~ .mock)
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
    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

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
    Current.database = .mock
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
    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.createSubscription .~ { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }
    )

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
    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.createSubscription .~ { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }
    )

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      pricing: .init(billing: .monthly, quantity: 3),
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
    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.createSubscription .~ { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }
    )

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      pricing: .init(billing: .monthly, quantity: 3),
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
    update(
      &Current,
      \.database .~ .mock,
      \.database.createSubscription .~ { _, _, _ in throwE(unit as Error) },
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

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
