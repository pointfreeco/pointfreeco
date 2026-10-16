import Database
import Dependencies
import Either
import Foundation
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
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.record = true
  }

  @MainActor
  func testDelayedChangeResponsePreservesNewestTierAndBillsOnlyOnceAcrossRetries() async throws {
    var currentSubscription = Stripe.Subscription.mock
    currentSubscription.plan = .modernPersonalYearly
    currentSubscription.items.data[0].plan = .modernPersonalYearly
    var delayedUpdateResponse = currentSubscription
    delayedUpdateResponse.plan = .modernMaxYearly
    delayedUpdateResponse.items.data[0].plan = .modernMaxYearly
    var latestSubscription = currentSubscription
    latestSubscription.status = .trialing
    let latestSubscriptionValue = latestSubscription
    let pricing = Pricing(plan: .max, billing: .yearly, quantity: 1)
    let store = LockIsolated(
      Database.SubscriptionSnapshot(subscription: .mock, version: "v1")
    )
    let billingUpdates = LockIsolated(0)
    let stripeFetches = LockIsolated(0)
    let rejectedWrites = LockIsolated(0)
    let acceptedWrites = LockIsolated(0)
    let operations = LockIsolated<[String]>([])

    let result = await withDependencies {
      $0.failing()
      $0.currentUser = .mock
      $0.envVars.stripe.productId = "prod_test"
      $0.stripe.fetchPricesForProduct = { productID, lookupKeys in
        XCTAssertEqual(productID, "prod_test")
        if lookupKeys == ["pointfree-max"] {
          operations.withValue { $0.append("resolvePrice") }
          return .mock([.pointFreeMax])
        }
        XCTAssertEqual(
          Set(lookupKeys),
          Set<Stripe.Price.LookupKey>(["pointfree-max", "pointfree-monthly", "pointfree-pro"])
        )
        operations.withValue { $0.append("prices") }
        return .mock([.pointFreeMonthly, .pointFreePro, .pointFreeMax])
      }
      $0.stripe.updateSubscription = { incoming, planID, quantity in
        XCTAssertEqual(incoming, currentSubscription)
        XCTAssertEqual(planID.rawValue, Stripe.Price.pointFreeMax.id.rawValue)
        XCTAssertEqual(quantity, 1)
        billingUpdates.withValue { $0 += 1 }
        operations.withValue { $0.append("billing") }
        return delayedUpdateResponse
      }
      $0.database.fetchSubscriptionSnapshot = { id in
        XCTAssertEqual(id, delayedUpdateResponse.id)
        operations.withValue { $0.append("snapshot") }
        return store.value
      }
      $0.stripe.fetchSubscription = { id in
        XCTAssertEqual(id, delayedUpdateResponse.id)
        operations.withValue { $0.append("stripe") }
        let attempt = stripeFetches.withValue {
          $0 += 1
          return $0
        }
        if attempt == 1 {
          // A newer Pro change commits while reconciliation awaits Stripe.
          store.withValue {
            var newer = $0.subscription
            newer.plan = .pro
            newer.stripeSubscriptionStatus = .trialing
            $0 = .init(subscription: newer, version: "v2")
          }
          return currentSubscription
        }
        return latestSubscriptionValue
      }
      $0.database.updateStripeSubscriptionIfUnchanged = { incoming, plan, snapshot in
        XCTAssertEqual(plan, .pro, "Use the authoritative tier, not the delayed Max response")
        operations.withValue { $0.append("write") }
        return store.withValue { current in
          guard snapshot.version == current.version else {
            rejectedWrites.withValue { $0 += 1 }
            return nil
          }
          XCTAssertEqual(snapshot.version, "v2")
          XCTAssertEqual(incoming, latestSubscriptionValue)
          acceptedWrites.withValue { $0 += 1 }
          var updated = current.subscription
          updated.stripeSubscriptionStatus = incoming.status
          if let plan { updated.plan = plan }
          current = .init(subscription: updated, version: "v3")
          return updated
        }
      }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn)
      ).map { _ in (currentSubscription, pricing) }

      return await changeSubscription(
        error: { error in
          { conn in
            IO {
              XCTFail("Unexpected subscription-change error: \(error)")
              return conn.writeStatus(.badRequest).respond(text: "failed")
            }
          }
        },
        success: { conn in
          IO {
            operations.withValue { $0.append("success") }
            return conn.writeStatus(.ok).respond(text: "updated")
          }
        }
      )(conn).performAsync()
    }

    XCTAssertEqual(String(decoding: result.data, as: UTF8.self), "updated")
    XCTAssertEqual(billingUpdates.value, 1)
    XCTAssertEqual(stripeFetches.value, 2)
    XCTAssertEqual(rejectedWrites.value, 1)
    XCTAssertEqual(acceptedWrites.value, 1)
    XCTAssertEqual(store.value.subscription.plan, .pro)
    XCTAssertEqual(store.value.subscription.stripeSubscriptionStatus, .trialing)
    XCTAssertEqual(
      operations.value,
      [
        "resolvePrice", "billing", "snapshot", "stripe", "prices", "write",
        "snapshot", "stripe", "prices", "write", "success",
      ]
    )
  }

  @MainActor
  func testChangeRedirect() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .individualMonthly }
      } operation: {
        let conn = connection(
          from: request(to: .account(.subscription(.change(.show))), session: .loggedIn))
        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateUpgradeIndividualPlan() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .individualMonthly }
        $0.stripe.invoiceCustomer = { _ in
          XCTFail()
          return .mock(charge: .right(.mock))
        }
      } operation: {
        let conn = connection(
          from: request(
            to: .account(.subscription(.change(.update(.individualYearly)))), session: .loggedIn))
        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateDowngradeIndividualPlan() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .individualYearly }
        $0.stripe.invoiceCustomer = { _ in
          XCTFail()
          return .mock(charge: .right(.mock))
        }
      } operation: {
        let conn = connection(
          from: request(
            to: .account(.subscription(.change(.update(.individualMonthly)))), session: .loggedIn))
        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateUpgradeTeamPlan() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .teamMonthly }
        $0.stripe.invoiceCustomer = { _ in
          XCTFail()
          return .mock(charge: .right(.mock))
        }
      } operation: {
        let conn = connection(
          from: request(
            to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))
        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateDowngradeTeamPlan() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .individualYearly }
        $0.stripe.invoiceCustomer = { _ in
          XCTFail()
          return .mock(charge: .right(.mock))
        }
      } operation: {
        let conn = connection(
          from: request(
            to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))
        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateAddSeatsIndividualPlan() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .individualMonthly }
      } operation: {
        let conn = connection(
          from: request(
            to: .account(.subscription(.change(.update(.teamMonthly)))), session: .loggedIn))
        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpgradeIndividualMonthlyToTeamYearly() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .individualMonthly }
      } operation: {
        let conn = connection(
          from: request(
            to: .account(.subscription(.change(.update(.teamYearly)))), session: .loggedIn))
        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateAddSeatsTeamPlan() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .teamMonthly }
      } operation: {
        var pricing = Pricing.teamMonthly
        pricing.quantity += 4

        let conn = connection(
          from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn))
        let result = await siteMiddleware(conn)
        await assertSnapshot(matching: result, as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateRemoveSeats() async throws {
    #if !os(Linux)
      await withDependencies {
        $0.stripe.fetchSubscription = { _ in .teamMonthly }
        $0.stripe.invoiceCustomer = { _ in
          XCTFail()
          return .mock(charge: .right(.mock))
        }
      } operation: {
        var pricing = Pricing.teamMonthly
        pricing.quantity -= 1

        let conn = connection(
          from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn))

        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }

  @MainActor
  func testChangeUpdateRemoveSeatsInvalidNumber() async throws {
    #if !os(Linux)
      var subscription = Stripe.Subscription.mock
      subscription.plan = .teamYearly
      subscription.quantity = 5

      await withDependencies {
        $0.database.fetchSubscriptionTeammatesByOwnerId = { _ in [.teammate, .teammate] }
        $0.database.fetchTeamInvites = { _ in [.mock, .mock] }
        $0.stripe.fetchSubscription = { _ in subscription }
      } operation: {
        var pricing = Pricing.teamYearly
        pricing.quantity = 3

        let conn = connection(
          from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn)
        )

        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      }
    #endif
  }
}
