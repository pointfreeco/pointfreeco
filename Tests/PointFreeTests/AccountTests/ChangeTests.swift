import Either
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree
@testable import Stripe

#if !os(Linux)
  import WebKit
#endif

final class ChangeTests: TestCase {
  override func setUp() {
    super.setUp()
    //    record = true
  }

  func testChangeRedirect() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.individualMonthly))

      let conn = connection(
        from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateUpgradeIndividualPlan() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.individualMonthly))
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.individualYearly)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateDowngradeIndividualPlan() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.individualYearly))
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.individualMonthly)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateUpgradeTeamPlan() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.teamMonthly))
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateDowngradeTeamPlan() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.individualYearly))
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateAddSeatsIndividualPlan() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.individualMonthly))

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpgradeIndividualMonthlyToTeamYearly() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.individualMonthly))

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateAddSeatsTeamPlan() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.teamMonthly))
      var pricing = Pricing.teamMonthly
      pricing.quantity += 4

      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn))
      let result = conn |> siteMiddleware

      let performed = result.perform()
      assertSnapshot(matching: performed, as: .conn)
    #endif
  }

  func testChangeUpdateRemoveSeats() {
    #if !os(Linux)
      Current.stripe.fetchSubscription = const(pure(.teamMonthly))
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
      var pricing = Pricing.teamMonthly
      pricing.quantity -= 1

      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateRemoveSeatsInvalidNumber() {
    #if !os(Linux)
      var subscription = Stripe.Subscription.mock
      subscription.plan = .teamYearly
      subscription.quantity = 5

      Current.database.fetchSubscriptionTeammatesByOwnerId = const(pure([.teammate, .teammate]))
      Current.database.fetchTeamInvites = const(pure([.mock, .mock]))
      Current.stripe.fetchSubscription = const(pure(subscription))

      var pricing = Pricing.teamYearly
      pricing.quantity = 3

      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn))

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }
}
