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

  func testNotLoggedIn() {
    let conn = connection(from: request(to: .subscribe(.some(.individualMonthly))))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn)
  }

  func testCurrentSubscribers() {
    let conn = connection(
      from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn)
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

      assertSnapshot(matching: conn, named: "too_high")
    }

    AppEnvironment.with(\.database.fetchSubscriptionById .~ const(pure(nil))) {
      let conn = connection(
        from: request(to: .subscribe(.some(.teamYearly(quantity: 1))), session: .loggedIn)
        )
        |> siteMiddleware
        |> Prelude.perform

      assertSnapshot(matching: conn, named: "too_low")
    }
  }

  func testHappyPath() {
    AppEnvironment.with(\.database .~ .live) {
      let user = AppEnvironment.current.database.upsertUser(.mock)
        .run
        .perform()
        .right!!
      let session = Session.loggedIn |> \.userId .~ user.id

      let conn = connection(
        from: request(to: .subscribe(.some(.individualMonthly)), session: session)
        )
        |> siteMiddleware
        |> Prelude.perform

      assertSnapshot(matching: conn)

      let subscription = AppEnvironment.current.database.fetchSubscriptionByOwnerId(user.id)
        .run
        .perform()
        .right!!

      assertSnapshot(matching: subscription)
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

      assertSnapshot(matching: conn)
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

      assertSnapshot(matching: conn)
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

      assertSnapshot(matching: conn)
    }
  }
}
