import CustomDump
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
  func testAppliedChangeWithRefreshFailureDoesNotSuggestRetryingBilling() async throws {
    struct RefreshFailure: Error {}

    let pricing = Pricing(plan: .max, billing: .yearly, quantity: 1)
    let billingUpdates = LockIsolated(0)
    let result = await withDependencies {
      $0.failing()
      $0.envVars.stripe.productId = "prod_test"
      $0.stripe.fetchPricesForProduct = { _, _ in .mock([.pointFreeMax]) }
      $0.stripe.updateSubscription = { _, _, _ in
        billingUpdates.withValue { $0 += 1 }
        return .mock
      }
      $0.database.fetchSubscriptionSnapshot = { _ in throw RefreshFailure() }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.change(.update(pricing)))), session: .loggedIn)
      ).map { _ in (Stripe.Subscription.mock, pricing) }

      return await changeSubscription(
        error: subscriptionModificationErrorMiddleware,
        success: { conn in
          IO {
            XCTFail("A failed access refresh must use the error response")
            return conn.writeStatus(.ok).respond(text: "updated")
          }
        }
      )(conn).performAsync()
    }

    XCTAssertEqual(billingUpdates.value, 1)
    expectNoDifference(result.response.status.rawValue, 302)
    expectNoDifference(result.response.headers.first { $0.name == "Location" }?.value, "/account")
    let cookie = try XCTUnwrap(
      result.response.headers.first { $0.name == "Set-Cookie" }?.value
    )
    var nextRequest = result.request
    nextRequest.setValue(cookie, forHTTPHeaderField: "Cookie")
    expectNoDifference(
      nextRequest.session.flash,
      Flash(
        .error,
        """
        Your membership change was applied, but we couldn’t refresh your account access. \
        Please reload your account or contact <support@pointfree.co>. Do not submit the change again.
        """
      )
    )
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

    let result = await withDependencies {
      $0.failing()
      $0.currentUser = .mock
      $0.envVars.stripe.productId = "prod_test"
      $0.stripe.fetchPricesForProduct = { productID, lookupKeys in
        XCTAssertEqual(productID, "prod_test")
        if lookupKeys == ["pointfree-max"] {
          return .mock([.pointFreeMax])
        }
        expectNoDifference(
          Set(lookupKeys),
          Set<Stripe.Price.LookupKey>(["pointfree-max", "pointfree-monthly", "pointfree-pro"])
        )
        return .mock([.pointFreeMonthly, .pointFreePro, .pointFreeMax])
      }
      $0.stripe.updateSubscription = { incoming, planID, quantity in
        expectNoDifference(incoming, currentSubscription)
        XCTAssertEqual(planID.rawValue, Stripe.Price.pointFreeMax.id.rawValue)
        XCTAssertEqual(quantity, 1)
        billingUpdates.withValue { $0 += 1 }
        return delayedUpdateResponse
      }
      $0.database.fetchSubscriptionSnapshot = { id in
        XCTAssertEqual(id, delayedUpdateResponse.id)
        return store.value
      }
      $0.stripe.fetchSubscription = { id in
        XCTAssertEqual(id, delayedUpdateResponse.id)
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
        return store.withValue { current in
          guard snapshot.version == current.version else {
            return nil
          }
          XCTAssertEqual(snapshot.version, "v2")
          expectNoDifference(incoming, latestSubscriptionValue)
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
            return conn.writeStatus(.ok).respond(text: "updated")
          }
        }
      )(conn).performAsync()
    }

    XCTAssertEqual(String(decoding: result.data, as: UTF8.self), "updated")
    XCTAssertEqual(billingUpdates.value, 1)
    XCTAssertEqual(stripeFetches.value, 2)
    XCTAssertEqual(store.value.subscription.plan, .pro)
    XCTAssertEqual(store.value.subscription.stripeSubscriptionStatus, .trialing)
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
