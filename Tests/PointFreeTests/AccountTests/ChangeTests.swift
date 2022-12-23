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

@MainActor
final class ChangeTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.record = true
  }

  func testChangeRedirect() async throws {
    #if !os(Linux)
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

      let conn = connection(
        from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateUpgradeIndividualPlan() async throws {
    #if !os(Linux)
    Current.stripe.fetchSubscription = { _ in .individualMonthly }
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.individualYearly)))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateDowngradeIndividualPlan() async throws {
    #if !os(Linux)
      Current.stripe.fetchSubscription = { _ in .individualYearly }
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.individualMonthly)))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateUpgradeTeamPlan() async throws {
    #if !os(Linux)
      Current.stripe.fetchSubscription = { _ in .teamMonthly }
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateDowngradeTeamPlan() async throws {
    #if !os(Linux)
      Current.stripe.fetchSubscription = { _ in .individualYearly }
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateAddSeatsIndividualPlan() async throws {
    #if !os(Linux)
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpgradeIndividualMonthlyToTeamYearly() async throws {
    #if !os(Linux)
    Current.stripe.fetchSubscription = { _ in .individualMonthly }

      let conn = connection(
        from: request(
          to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateAddSeatsTeamPlan() async throws {
    #if !os(Linux)
      Current.stripe.fetchSubscription = { _ in .teamMonthly }
      var pricing = Pricing.teamMonthly
      pricing.quantity += 4

      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn))
      let result = conn |> siteMiddleware

      let performed = await result.performAsync()
      await assertSnapshot(matching: performed, as: .conn)
    #endif
  }

  func testChangeUpdateRemoveSeats() async throws {
    #if !os(Linux)
      Current.stripe.fetchSubscription = { _ in .teamMonthly }
      Current.stripe.invoiceCustomer = { _ in
        XCTFail()
        return pure(.mock(charge: .right(.mock)))
      }
      var pricing = Pricing.teamMonthly
      pricing.quantity -= 1

      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn))

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testChangeUpdateRemoveSeatsInvalidNumber() async throws {
    #if !os(Linux)
      var subscription = Stripe.Subscription.mock
      subscription.plan = .teamYearly
      subscription.quantity = 5

      Current.database.fetchSubscriptionTeammatesByOwnerId = { _ in [.teammate, .teammate] }
      Current.database.fetchTeamInvites = { _ in [.mock, .mock] }
      Current.stripe.fetchSubscription = { _ in subscription }

      var pricing = Pricing.teamYearly
      pricing.quantity = 3

      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn)
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }
}
