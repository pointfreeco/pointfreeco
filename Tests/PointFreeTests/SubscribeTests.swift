import Either
@testable import GitHub
import Html
import HttpPipeline
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
@testable import Stripe
import XCTest

final class SubscribeTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testNotLoggedIn_IndividualMonthly() {
    let conn = connection(from: request(to: .subscribe(.some(.individualMonthly))))
      |> siteMiddleware
      |> Prelude.perform
    update(&Current, \.database .~ .mock)

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCoupon_Individual() {
    let subscribeData = SubscribeData.individualMonthly
      |> \.coupon .~ "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    let session = Session.loggedIn |> \.userId .~ user.id

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
    let session = Session.loggedIn |> \.userId .~ user.id

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

  // TODO: dont know how to get this route to recognize.
  //  func testMissingSubscriberData() {
  //    let req = request(to: .subscribe(nil), session: .loggedIn)
  //    let conn = connection(from: req)
  //      |> siteMiddleware
  //      |> Prelude.perform
  //
  //    assertSnapshot(matching: conn, as: .conn)
  //  }

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

  func testHappyPath() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!
    let session = Session.loggedIn |> \.userId .~ user.id

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

  func testCreateCustomerFailure() {
    update(
      &Current,
      \.database .~ .mock,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.createCustomer .~ { _, _, _, _ in throwE(unit as Error) }
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

  func testCreateDatabaseSubscriptionFailure() {
    update(
      &Current,
      \.database .~ .mock,
      \.database.createSubscription .~ { _, _ in throwE(unit as Error) },
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
