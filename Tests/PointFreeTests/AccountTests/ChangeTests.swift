import Either
import Html
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

final class ChangeTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testChangeShow() {
    let conn = connection(from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1800))
        ]
      )
    }
    #endif
  }

  func testChangeShowLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.change(.show))), session: .loggedOut))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testChangeShowNoSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(throwE(unit)))

    let conn = connection(from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testChangeShowCancelingSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceling)))

    let conn = connection(from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1800))
        ]
      )
    }
    #endif
  }

  func testChangeShowCanceledSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceled)))

    let conn = connection(from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testChangeShowDiscountSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.discounted)))

    let conn = connection(from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1800))
        ]
      )
    }
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
