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

final class SubscribeTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
  }

  func testNotLoggedIn_IndividualMonthly() {
    let conn = connection(from: request(to: .subscribe(.some(.individualMonthly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn)
    #endif
  }

  func testCoupon_Individual() {
    let subscribeData = SubscribeData.individualMonthly
      |> \.coupon .~ "deadbeef"
    update(&Current, \.database .~ .live)

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
    assertSnapshot(matching: conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
    assertSnapshot(matching: subscription)
    #endif
  }

  func testCoupon_Team() {
    let subscribeData = SubscribeData.teamYearly(quantity: 4)
      |> \.coupon .~ "deadbeef"
    update(&Current, \.database .~ .live)

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
    assertSnapshot(matching: conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!
    XCTAssertNil(subscription)
  }

  func testNotLoggedIn_IndividualYearly() {
    let conn = connection(from: request(to: .subscribe(.some(.individualYearly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn)
    #endif
  }

  func testNotLoggedIn_Team() {
    let conn = connection(from: request(to: .subscribe(.some(.teamYearly(quantity: 5)))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn)
    #endif
  }

  func testCurrentSubscribers() {
    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn)
    #endif
  }

  // TODO: dont know how to get this route to recognize.
  //  func testMissingSubscriberData() {
  //    let req = request(to: .subscribe(nil), session: .loggedIn)
  //    let conn = connection(from: req)
  //      |> siteMiddleware
  //      |> Prelude.perform
  //
  //    assertSnapshot(matching: conn)
  //  }

  func testInvalidQuantity() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(to: .subscribe(.some(.teamYearly(quantity: 200))), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, named: "too_high")
    #endif

    let conn2 = connection(
      from: request(to: .subscribe(.some(.teamYearly(quantity: 1))), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn2, named: "too_low")
    #endif
  }

  func testHappyPath() {
    update(&Current, \.database .~ .live)

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
      assertSnapshot(matching: conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
      assertSnapshot(matching: subscription)
    #endif
  }

  func testCreateCustomerFailure() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.createCustomer .~ { _, _, _ in throwE(unit as Error) }
    )

    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn)
    #endif
  }

  func testCreateStripeSubscriptionFailure() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.createSubscription .~ { _, _, _, _ in throwE(Stripe.ErrorEnvelope.mock as Error) }
    )

    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn)
    #endif
  }

  func testCreateDatabaseSubscriptionFailure() {
    update(
      &Current, 
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
      assertSnapshot(matching: conn)
    #endif
  }
}
