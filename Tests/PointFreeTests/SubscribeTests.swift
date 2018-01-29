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
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testNotLoggedIn_IndividualMonthly() {
    let conn = connection(from: request(to: .subscribe(.some(.individualMonthly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn)
    #endif
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
    AppEnvironment.with(\.database.fetchSubscriptionById .~ const(pure(nil))) {
      let conn = connection(
        from: request(to: .subscribe(.some(.teamYearly(quantity: 200))), session: .loggedIn)
        )
        |> siteMiddleware
        |> Prelude.perform

      #if !os(Linux)
        assertSnapshot(matching: conn, named: "too_high")
      #endif
    }

    AppEnvironment.with(\.database.fetchSubscriptionById .~ const(pure(nil))) {
      let conn = connection(
        from: request(to: .subscribe(.some(.teamYearly(quantity: 1))), session: .loggedIn)
        )
        |> siteMiddleware
        |> Prelude.perform

      #if !os(Linux)
        assertSnapshot(matching: conn, named: "too_low")
      #endif
    }
  }

  func testHappyPath() {
    AppEnvironment.with(\.database .~ .live) {
      let user = AppEnvironment.current.database.upsertUser(.mock, EmailAddress(unwrap: "hello@pointfree.co"))
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

      let subscription = AppEnvironment.current.database.fetchSubscriptionByOwnerId(user.id)
        .run
        .perform()
        .right!!

      #if !os(Linux)
        assertSnapshot(matching: subscription)
      #endif
    }
  }

  func testCreateCustomerFailure() {
    AppEnvironment.with(
      (\.stripe.createCustomer .~ { _, _ in throwE(unit) })
        <> (\.database.fetchSubscriptionById .~ const(pure(nil)))
    ) {
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

  func testCreateStripeSubscriptionFailure() {
    AppEnvironment.with(
      (\.stripe.createSubscription .~ { _, _, _ in throwE(unit) })
        <> (\.database.fetchSubscriptionById .~ const(pure(nil)))
    ) {
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

  func testCreateDatabaseSubscriptionFailure() {
    AppEnvironment.with(
      (\.database.createSubscription .~ { _, _ in throwE(unit as Error) })
        <> (\.database.fetchSubscriptionById .~ const(pure(nil)))
    ) {
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
}
