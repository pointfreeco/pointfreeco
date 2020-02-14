import Either
import HttpPipeline
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
@testable import Stripe
#if !os(Linux)
import WebKit
#endif
import XCTest

final class ChangeTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testChangeRedirect() {
    #if !os(Linux)
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.individualMonthly))
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateUpgradeIndividualPlan() {
    #if !os(Linux)
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.individualMonthly)),
      \.stripe.invoiceCustomer .~ { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.individualYearly)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateDowngradeIndividualPlan() {
    #if !os(Linux)
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.individualYearly)),
      \.stripe.invoiceCustomer .~ { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.individualMonthly)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateUpgradeTeamPlan() {
    #if !os(Linux)
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.teamMonthly)),
      \.stripe.invoiceCustomer .~ { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateDowngradeTeamPlan() {
    #if !os(Linux)
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.individualYearly)),
      \.stripe.invoiceCustomer .~ { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateAddSeatsIndividualPlan() {
//    record = true
    #if !os(Linux)
    let invoiceCustomer = expectation(description: "invoiceCustomer")
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.individualMonthly)),
      \.stripe.invoiceCustomer .~ { _ in
        invoiceCustomer.fulfill()
        return pure(.mock(charge: .right(.mock)))
      }
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    waitForExpectations(timeout: 0.1, handler: nil)
    #endif
  }

  func testChangeUpgradeIndividualMonthlyToTeamYearly() {
    #if !os(Linux)
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.individualMonthly)),
      \.stripe.invoiceCustomer .~ { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateAddSeatsTeamPlan() {
    #if !os(Linux)
    let invoiceCustomer = expectation(description: "invoiceCustomer")
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.teamMonthly)),
      \.stripe.invoiceCustomer .~ { _ in
        invoiceCustomer.fulfill()
        return pure(.mock(charge: .right(.mock)))
      }
    )
    let conn = connection(from: request(to: .account(.subscription(.change(.update(.teamMonthly |> \.quantity +~ 4)))), session: .loggedIn))
    let result = conn |> siteMiddleware

    let performed = result.perform()
    waitForExpectations(timeout: 0.1, handler: nil)
    assertSnapshot(matching: performed, as: .conn)
    #endif
  }

  func testChangeUpdateRemoveSeats() {
    #if !os(Linux)
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.teamMonthly)),
      \.stripe.invoiceCustomer .~ { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.teamMonthly |> \.quantity -~ 1)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateRemoveSeatsInvalidNumber() {
    #if !os(Linux)
    let subscription = Stripe.Subscription.mock
      |> \.plan .~ .teamYearly
      |> \.quantity .~ 5

    update(
      &Current,
      (\Environment.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([.teammate, .teammate])),
      \.database.fetchTeamInvites .~ const(pure([.mock, .mock])),
      \.stripe.fetchSubscription .~ const(pure(subscription))
    )

    let conn = connection(from: request(to: .account(.subscription(.change(.update(.teamYearly |> \.quantity .~ 3)))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }
}
