import CustomDump
import Database
import Dependencies
import GitHubTestSupport
import Models
import ModelsTestSupport
import PointFreeTestSupport
import StripeTestSupport
import XCTest

@testable import PointFree
@testable import Stripe

final class StripeSubscriptionSyncTests: TestCase {
  @MainActor
  func testPaidUpgradeRefreshesStatusAndLocalMembership() async throws {
    try await assertSynchronization(
      localPlan: .pro,
      stripeSubscription: subscription(plan: .modernMaxYearly),
      resolvedPlan: .max
    )
  }

  @MainActor
  func testPaidDowngradeRefreshesMembershipAndRemovesBetaAccess() async throws {
    try await assertSynchronization(
      localPlan: .max,
      stripeSubscription: subscription(plan: .modernPersonalYearly),
      resolvedPlan: .pro
    )
  }

  @MainActor
  func testUnchangedTierKeepsMembership() async throws {
    try await assertSynchronization(
      localPlan: .max,
      stripeSubscription: subscription(plan: .modernMaxYearly),
      resolvedPlan: .max
    )
  }

  @MainActor
  func testUnknownPricePreservesMembershipWhileRefreshingStatus() async throws {
    var stripeSubscription = subscription(plan: .mock)
    stripeSubscription.status = .canceled

    try await assertSynchronization(
      localPlan: .max,
      stripeSubscription: stripeSubscription,
      resolvedPlan: nil
    )
  }

  @MainActor
  func testPriceLookupFailureRefreshesStatusAndThrowsForWebhookRetry() async throws {
    struct PriceLookupFailure: Error {}

    var stripeSubscription = subscription(plan: .modernMaxYearly)
    stripeSubscription.status = .unpaid
    let persistedSubscription = LockIsolated(Models.Subscription.mock)

    do {
      _ = try await withDependencies {
        $0.failing()
        $0.database.fetchSubscriptionSnapshot = { id in
          XCTAssertEqual(id, stripeSubscription.id)
          return .init(subscription: persistedSubscription.value, version: "v1")
        }
        $0.stripe.fetchSubscription = { id in
          XCTAssertEqual(id, stripeSubscription.id)
          return stripeSubscription
        }
        $0.stripe.fetchPricesForProduct = { _, _ in
          throw PriceLookupFailure()
        }
        $0.database.updateStripeSubscriptionIfUnchanged = { incoming, plan, snapshot in
          expectNoDifference(incoming, stripeSubscription)
          XCTAssertNil(plan)
          XCTAssertEqual(snapshot.version, "v1")
          return persistedSubscription.withValue {
            $0.stripeSubscriptionStatus = incoming.status
            return $0
          }
        }
      } operation: {
        try await synchronizeStripeSubscription(id: stripeSubscription.id)
      }
      XCTFail("Expected lookup failure to propagate so webhook delivery can be retried")
    } catch is PriceLookupFailure {}
    XCTAssertEqual(persistedSubscription.value.stripeSubscriptionStatus, .unpaid)
    XCTAssertEqual(persistedSubscription.value.plan, .pro)
  }

  @MainActor
  func testFreeFirstYearStillSynchronizesTheRenewingMaxTier() async throws {
    var stripeSubscription = subscription(plan: .modernMaxYearly)
    stripeSubscription.discount = .mock
    stripeSubscription.discount?.coupon.duration = .once
    stripeSubscription.discount?.coupon.rate = .percentOff(100)
    stripeSubscription.discount?.coupon.name = "Free first year"
    var customer = Stripe.Customer.mock
    customer.balance = -349_00
    stripeSubscription.customer = .right(customer)

    try await assertSynchronization(
      localPlan: .pro,
      stripeSubscription: stripeSubscription,
      resolvedPlan: .max
    )
  }

  @MainActor
  func testTrialSynchronizesMembershipWithoutChangingBilling() async throws {
    var stripeSubscription = subscription(plan: .modernMaxYearly)
    stripeSubscription.status = .trialing

    try await assertSynchronization(
      localPlan: .pro,
      stripeSubscription: stripeSubscription,
      resolvedPlan: .max
    )
  }

  @MainActor
  func testRejectedStaleMaxDoesNotOverwriteNewerPro() async throws {
    try await assertConflictRetry(
      originalPlan: .max,
      staleStripePlan: .modernMaxYearly,
      concurrentPlan: .pro,
      currentStripePlan: .modernPersonalYearly
    )
  }

  @MainActor
  func testRejectedStaleProDoesNotOverwriteNewerMax() async throws {
    try await assertConflictRetry(
      originalPlan: .pro,
      staleStripePlan: .modernPersonalYearly,
      concurrentPlan: .max,
      currentStripePlan: .modernMaxYearly
    )
  }

  @MainActor
  func testABAConflictRetriesWithoutRemovingBetaAccessForRejectedDowngrade() async throws {
    try await assertConflictRetry(
      originalPlan: .max,
      staleStripePlan: .modernPersonalYearly,
      concurrentPlan: .max,
      currentStripePlan: .modernMaxYearly,
      simulateABA: true
    )
  }

  @MainActor
  func testCatalogFailureStatusWriteConflictRetriesFreshState() async throws {
    try await assertConflictRetry(
      originalPlan: .max,
      staleStripePlan: .modernMaxYearly,
      concurrentPlan: .pro,
      currentStripePlan: .modernPersonalYearly,
      failFirstCatalogLookup: true
    )
  }

  @MainActor
  func testConflictsExhaustRetriesAndThrow() async throws {
    let snapshotCount = LockIsolated(0)
    let stripeSubscription = subscription(plan: .modernMaxYearly)

    do {
      _ = try await withDependencies {
        $0.failing()
        $0.envVars.stripe.productId = "prod_test"
        $0.database.fetchSubscriptionSnapshot = { _ in
          let version = snapshotCount.withValue {
            $0 += 1
            return "v\($0)"
          }
          return .init(subscription: .mock, version: version)
        }
        $0.stripe.fetchSubscription = { _ in stripeSubscription }
        $0.stripe.fetchPricesForProduct = { _, _ in .mock([.pointFreeMax]) }
        $0.database.updateStripeSubscriptionIfUnchanged = { _, plan, snapshot in
          XCTAssertEqual(plan, .max)
          XCTAssertEqual(snapshot.version, "v\(snapshotCount.value)")
          return nil
        }
      } operation: {
        try await synchronizeStripeSubscription(id: stripeSubscription.id)
      }
      XCTFail("Expected concurrent modification after three rejected writes")
    } catch SubscriptionSynchronizationError.concurrentModification {
    }

    XCTAssertEqual(snapshotCount.value, 3)
  }

  @MainActor
  func testValidationFailurePreventsCatalogLookupAndAllWrites() async throws {
    struct SkipSubscription: Error {}

    let stripeSubscription = subscription(plan: .modernMaxYearly)

    do {
      _ = try await withDependencies {
        $0.failing()
        $0.database.fetchSubscriptionSnapshot = { _ in .init(subscription: .mock, version: "v1") }
        $0.stripe.fetchSubscription = { _ in stripeSubscription }
      } operation: {
        try await synchronizeStripeSubscription(id: stripeSubscription.id) { incoming in
          expectNoDifference(incoming, stripeSubscription)
          throw SkipSubscription()
        }
      }
      XCTFail("Expected the validation error without a database write")
    } catch is SkipSubscription {}
  }

  @MainActor
  private func assertSynchronization(
    localPlan: Pricing.Plan,
    stripeSubscription: Stripe.Subscription,
    resolvedPlan: Pricing.Plan?,
    file: StaticString = #filePath,
    line: UInt = #line
  ) async throws {
    var initialSubscription = Models.Subscription.mock
    initialSubscription.plan = localPlan
    initialSubscription.stripeSubscriptionStatus = .pastDue
    let initialSubscriptionValue = initialSubscription
    let removedRepos = LockIsolated<[String]>([])
    let expectedPlan = resolvedPlan ?? localPlan
    let isDowngrade = localPlan == .max && expectedPlan == .pro

    let result = try await withDependencies {
      $0.failing()
      $0.envVars.stripe.productId = "prod_test"
      $0.database.fetchSubscriptionSnapshot = { id in
        XCTAssertEqual(id, stripeSubscription.id, file: file, line: line)
        return .init(subscription: initialSubscriptionValue, version: "v1")
      }
      $0.stripe.fetchSubscription = { id in
        XCTAssertEqual(id, stripeSubscription.id, file: file, line: line)
        return stripeSubscription
      }
      $0.stripe.fetchPricesForProduct = { productID, lookupKeys in
        XCTAssertEqual(productID, "prod_test", file: file, line: line)
        expectNoDifference(
          Set(lookupKeys),
          Set<Stripe.Price.LookupKey>(["pointfree-monthly", "pointfree-pro", "pointfree-max"]),
          filePath: file,
          line: line
        )
        return .mock([.pointFreeMonthly, .pointFreePro, .pointFreeMax])
      }
      $0.database.updateStripeSubscriptionIfUnchanged = { incoming, plan, snapshot in
        expectNoDifference(incoming, stripeSubscription, filePath: file, line: line)
        XCTAssertEqual(snapshot.version, "v1", file: file, line: line)
        XCTAssertEqual(plan, resolvedPlan, file: file, line: line)
        var updated = snapshot.subscription
        updated.stripeSubscriptionStatus = incoming.status
        updated.plan = plan ?? updated.plan
        return updated
      }
      if isDowngrade {
        $0.database.fetchUserById = { userID in
          XCTAssertEqual(userID, initialSubscription.userId, file: file, line: line)
          return .mock
        }
        $0.database.fetchSubscriptionTeammatesByOwnerId = { _ in [] }
        $0.gitHub.fetchUserByUserID = { _, _ in .mock }
        $0.gitHub.removeRepoCollaborator = { owner, repo, username, _ in
          XCTAssertEqual(owner, "pointfreeco", file: file, line: line)
          XCTAssertEqual(username, "blob", file: file, line: line)
          removedRepos.withValue { $0.append(repo) }
        }
      }
    } operation: {
      try await synchronizeStripeSubscription(id: stripeSubscription.id)
    }

    expectNoDifference(result.stripeSubscription, stripeSubscription, filePath: file, line: line)
    XCTAssertEqual(
      result.subscription.stripeSubscriptionStatus, stripeSubscription.status, file: file,
      line: line
    )
    XCTAssertEqual(result.subscription.plan, expectedPlan, file: file, line: line)
    expectNoDifference(
      removedRepos.value.sorted(), isDowngrade ? Beta.all.map(\.repo).sorted() : [],
      filePath: file, line: line
    )
  }

  @MainActor
  private func assertConflictRetry(
    originalPlan: Pricing.Plan,
    staleStripePlan: Stripe.Plan,
    concurrentPlan: Pricing.Plan,
    currentStripePlan: Stripe.Plan,
    simulateABA: Bool = false,
    failFirstCatalogLookup: Bool = false,
    file: StaticString = #filePath,
    line: UInt = #line
  ) async throws {
    struct UnexpectedRetry: Error {}
    struct PriceLookupFailure: Error {}

    var originalSubscription = Models.Subscription.mock
    originalSubscription.plan = originalPlan
    let originalSubscriptionValue = originalSubscription
    let store = LockIsolated(
      Database.SubscriptionSnapshot(subscription: originalSubscriptionValue, version: "v1")
    )
    let staleStripeSubscription = subscription(plan: staleStripePlan)
    var currentStripeSubscription = subscription(plan: currentStripePlan)
    currentStripeSubscription.status = .trialing
    let currentStripeSubscriptionValue = currentStripeSubscription
    let fetchedStripeSubscriptions = LockIsolated(0)
    let validatedSubscriptions = LockIsolated<[Stripe.Subscription]>([])
    let concurrentVersion = simulateABA ? "v3" : "v2"

    let result = try await withDependencies {
      $0.failing()
      $0.envVars.stripe.productId = "prod_test"
      $0.database.fetchSubscriptionSnapshot = { id in
        XCTAssertEqual(id, staleStripeSubscription.id, file: file, line: line)
        return store.value
      }
      $0.stripe.fetchSubscription = { id in
        XCTAssertEqual(id, staleStripeSubscription.id, file: file, line: line)
        let attempt = fetchedStripeSubscriptions.withValue {
          $0 += 1
          return $0
        }
        if attempt == 1 {
          // Another writer commits while this attempt is awaiting Stripe.
          store.withValue { current in
            var concurrent = current.subscription
            concurrent.plan = concurrentPlan
            current = .init(subscription: concurrent, version: concurrentVersion)
          }
          return staleStripeSubscription
        }
        guard attempt == 2 else { throw UnexpectedRetry() }
        return currentStripeSubscriptionValue
      }
      $0.stripe.fetchPricesForProduct = { _, _ in
        if failFirstCatalogLookup, fetchedStripeSubscriptions.value == 1 {
          throw PriceLookupFailure()
        }
        return .mock([.pointFreeMonthly, .pointFreePro, .pointFreeMax])
      }
      $0.database.updateStripeSubscriptionIfUnchanged = { incoming, plan, snapshot in
        return store.withValue { current in
          guard snapshot.version == current.version else {
            expectNoDifference(incoming, staleStripeSubscription, filePath: file, line: line)
            XCTAssertEqual(snapshot.version, "v1", file: file, line: line)
            XCTAssertEqual(current.version, concurrentVersion, file: file, line: line)
            if failFirstCatalogLookup {
              XCTAssertNil(plan, file: file, line: line)
            }
            if simulateABA {
              XCTAssertEqual(
                snapshot.subscription.plan, current.subscription.plan, file: file, line: line
              )
            }
            return nil
          }
          expectNoDifference(incoming, currentStripeSubscriptionValue, filePath: file, line: line)
          XCTAssertEqual(plan, concurrentPlan, file: file, line: line)
          var updated = current.subscription
          updated.stripeSubscriptionStatus = incoming.status
          if let plan { updated.plan = plan }
          current = .init(subscription: updated, version: "committed")
          return updated
        }
      }
    } operation: {
      try await synchronizeStripeSubscription(id: staleStripeSubscription.id) { incoming in
        validatedSubscriptions.withValue { $0.append(incoming) }
      }
    }

    XCTAssertEqual(fetchedStripeSubscriptions.value, 2, file: file, line: line)
    expectNoDifference(
      validatedSubscriptions.value, [staleStripeSubscription, currentStripeSubscription],
      filePath: file, line: line
    )
    XCTAssertEqual(store.value.subscription.plan, concurrentPlan, file: file, line: line)
    XCTAssertEqual(
      store.value.subscription.stripeSubscriptionStatus, .trialing, file: file, line: line)
    XCTAssertEqual(result.subscription.plan, concurrentPlan, file: file, line: line)
    expectNoDifference(
      result.stripeSubscription, currentStripeSubscription, filePath: file, line: line)
  }

  private func subscription(plan: Stripe.Plan) -> Stripe.Subscription {
    var subscription = Stripe.Subscription.mock
    subscription.plan = plan
    subscription.items.data[0].plan = plan
    return subscription
  }
}
