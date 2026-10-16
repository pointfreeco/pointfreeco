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
    let operations = LockIsolated<[String]>([])

    do {
      _ = try await withDependencies {
        $0.failing()
        $0.database.fetchSubscriptionSnapshot = { id in
          XCTAssertEqual(id, stripeSubscription.id)
          operations.withValue { $0.append("snapshot") }
          return .init(subscription: persistedSubscription.value, version: "v1")
        }
        $0.stripe.fetchSubscription = { id in
          XCTAssertEqual(id, stripeSubscription.id)
          operations.withValue { $0.append("stripe") }
          return stripeSubscription
        }
        $0.stripe.fetchPricesForProduct = { _, _ in
          operations.withValue { $0.append("prices") }
          throw PriceLookupFailure()
        }
        $0.database.updateStripeSubscriptionIfUnchanged = { incoming, plan, snapshot in
          XCTAssertEqual(incoming, stripeSubscription)
          XCTAssertNil(plan)
          XCTAssertEqual(snapshot.version, "v1")
          operations.withValue { $0.append("write") }
          return persistedSubscription.withValue {
            $0.stripeSubscriptionStatus = incoming.status
            return $0
          }
        }
      } operation: {
        try await synchronizeStripeSubscription(id: stripeSubscription.id)
      }
      XCTFail("Expected lookup failure to propagate so webhook delivery can be retried")
    } catch is PriceLookupFailure {
      // The original error is returned after the status-only conditional write.
    }

    XCTAssertEqual(operations.value, ["snapshot", "stripe", "prices", "write"])
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
    let operations = LockIsolated<[String]>([])
    let snapshotCount = LockIsolated(0)
    let stripeSubscription = subscription(plan: .modernMaxYearly)

    do {
      _ = try await withDependencies {
        $0.failing()
        $0.envVars.stripe.productId = "prod_test"
        $0.database.fetchSubscriptionSnapshot = { _ in
          operations.withValue { $0.append("snapshot") }
          let version = snapshotCount.withValue {
            $0 += 1
            return "v\($0)"
          }
          return .init(subscription: .mock, version: version)
        }
        $0.stripe.fetchSubscription = { _ in
          operations.withValue { $0.append("stripe") }
          return stripeSubscription
        }
        $0.stripe.fetchPricesForProduct = { _, _ in
          operations.withValue { $0.append("prices") }
          return .mock([.pointFreeMax])
        }
        $0.database.updateStripeSubscriptionIfUnchanged = { _, plan, snapshot in
          XCTAssertEqual(plan, .max)
          XCTAssertEqual(snapshot.version, "v\(snapshotCount.value)")
          operations.withValue { $0.append("write") }
          return nil
        }
      } operation: {
        try await synchronizeStripeSubscription(id: stripeSubscription.id)
      }
      XCTFail("Expected concurrent modification after three rejected writes")
    } catch SubscriptionSynchronizationError.concurrentModification {
    }

    XCTAssertEqual(snapshotCount.value, 3)
    XCTAssertEqual(
      operations.value,
      Array(repeating: ["snapshot", "stripe", "prices", "write"], count: 3).flatMap { $0 }
    )
  }

  @MainActor
  func testValidationFailurePreventsCatalogLookupAndAllWrites() async throws {
    struct SkipSubscription: Error {}

    let stripeSubscription = subscription(plan: .modernMaxYearly)
    let operations = LockIsolated<[String]>([])

    do {
      _ = try await withDependencies {
        $0.failing()
        $0.database.fetchSubscriptionSnapshot = { _ in
          operations.withValue { $0.append("snapshot") }
          return .init(subscription: .mock, version: "v1")
        }
        $0.stripe.fetchSubscription = { _ in
          operations.withValue { $0.append("stripe") }
          return stripeSubscription
        }
      } operation: {
        try await synchronizeStripeSubscription(id: stripeSubscription.id) { incoming in
          XCTAssertEqual(incoming, stripeSubscription)
          operations.withValue { $0.append("validate") }
          throw SkipSubscription()
        }
      }
      XCTFail("Expected the validation error without a database write")
    } catch is SkipSubscription {
    }

    XCTAssertEqual(operations.value, ["snapshot", "stripe", "validate"])
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
    let persistedSubscription = LockIsolated(initialSubscriptionValue)
    let operations = LockIsolated<[String]>([])
    let removedRepos = LockIsolated<[String]>([])
    let expectedPlan = resolvedPlan ?? localPlan
    let isDowngrade = localPlan == .max && expectedPlan == .pro
    let betaAccessRemoved = isDowngrade ? expectation(description: "Beta access removed") : nil
    betaAccessRemoved?.expectedFulfillmentCount = Beta.all.count

    let result = try await withDependencies {
      // Unconfigured endpoints fail the test, including every Stripe mutation.
      $0.failing()
      $0.envVars.stripe.productId = "prod_test"
      $0.database.fetchSubscriptionSnapshot = { id in
        XCTAssertEqual(id, stripeSubscription.id, file: file, line: line)
        operations.withValue { $0.append("snapshot") }
        return .init(subscription: persistedSubscription.value, version: "v1")
      }
      $0.stripe.fetchSubscription = { id in
        XCTAssertEqual(id, stripeSubscription.id, file: file, line: line)
        operations.withValue { $0.append("stripe") }
        return stripeSubscription
      }
      $0.stripe.fetchPricesForProduct = { productID, lookupKeys in
        XCTAssertEqual(productID, "prod_test", file: file, line: line)
        XCTAssertEqual(
          Set(lookupKeys),
          Set<Stripe.Price.LookupKey>(["pointfree-monthly", "pointfree-pro", "pointfree-max"]),
          file: file,
          line: line
        )
        operations.withValue { $0.append("prices") }
        return .mock([.pointFreeMonthly, .pointFreePro, .pointFreeMax])
      }
      $0.database.updateStripeSubscriptionIfUnchanged = { incoming, plan, snapshot in
        XCTAssertEqual(incoming, stripeSubscription, file: file, line: line)
        XCTAssertEqual(snapshot.subscription.id, initialSubscription.id, file: file, line: line)
        XCTAssertEqual(snapshot.version, "v1", file: file, line: line)
        XCTAssertEqual(plan, resolvedPlan, file: file, line: line)
        operations.withValue { $0.append("write") }
        return persistedSubscription.withValue {
          $0.stripeSubscriptionStatus = incoming.status
          if let plan { $0.plan = plan }
          return $0
        }
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
          betaAccessRemoved?.fulfill()
        }
      }
    } operation: {
      try await synchronizeStripeSubscription(id: stripeSubscription.id)
    }

    if let betaAccessRemoved {
      await fulfillment(of: [betaAccessRemoved], timeout: 1)
    }

    XCTAssertEqual(result.stripeSubscription, stripeSubscription, file: file, line: line)
    XCTAssertEqual(result.subscription.id, initialSubscription.id, file: file, line: line)
    XCTAssertEqual(result.subscription.userId, initialSubscription.userId, file: file, line: line)
    XCTAssertEqual(
      result.subscription.stripeSubscriptionId, initialSubscription.stripeSubscriptionId,
      file: file, line: line
    )
    XCTAssertEqual(
      result.subscription.teamInviteCode, initialSubscription.teamInviteCode, file: file, line: line
    )
    XCTAssertEqual(
      result.subscription.deactivated, initialSubscription.deactivated, file: file, line: line
    )
    XCTAssertEqual(
      result.subscription.stripeSubscriptionStatus, stripeSubscription.status, file: file, line: line
    )
    XCTAssertEqual(result.subscription.plan, expectedPlan, file: file, line: line)
    XCTAssertEqual(persistedSubscription.value.plan, expectedPlan, file: file, line: line)
    XCTAssertEqual(
      operations.value, ["snapshot", "stripe", "prices", "write"], file: file, line: line
    )
    XCTAssertEqual(
      removedRepos.value.sorted(), isDowngrade ? Beta.all.map(\.repo).sorted() : [],
      file: file, line: line
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
    let operations = LockIsolated<[String]>([])
    let fetchedStripeSubscriptions = LockIsolated(0)
    let validatedSubscriptions = LockIsolated<[Stripe.Subscription]>([])
    let rejectedVersions = LockIsolated<[String]>([])
    let acceptedVersions = LockIsolated<[String]>([])
    let concurrentVersion = simulateABA ? "v3" : "v2"

    let result = try await withDependencies {
      // In particular, any beta-access side effect from the rejected attempt fails.
      $0.failing()
      $0.envVars.stripe.productId = "prod_test"
      $0.database.fetchSubscriptionSnapshot = { id in
        XCTAssertEqual(id, staleStripeSubscription.id, file: file, line: line)
        operations.withValue { $0.append("snapshot") }
        return store.value
      }
      $0.stripe.fetchSubscription = { id in
        XCTAssertEqual(id, staleStripeSubscription.id, file: file, line: line)
        operations.withValue { $0.append("stripe") }
        let attempt = fetchedStripeSubscriptions.withValue {
          $0 += 1
          return $0
        }
        if attempt == 1 {
          // Another writer commits while this attempt is awaiting Stripe.
          store.withValue { current in
            if simulateABA {
              var intermediate = current.subscription
              intermediate.plan = originalPlan == .max ? .pro : .max
              current = .init(subscription: intermediate, version: "v2")
            }
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
        operations.withValue { $0.append("prices") }
        if failFirstCatalogLookup, fetchedStripeSubscriptions.value == 1 {
          throw PriceLookupFailure()
        }
        return .mock([.pointFreeMonthly, .pointFreePro, .pointFreeMax])
      }
      $0.database.updateStripeSubscriptionIfUnchanged = { incoming, plan, snapshot in
        operations.withValue { $0.append("write") }
        return store.withValue { current in
          guard snapshot.version == current.version else {
            XCTAssertEqual(incoming, staleStripeSubscription, file: file, line: line)
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
            rejectedVersions.withValue { $0.append(snapshot.version) }
            return nil
          }
          XCTAssertEqual(incoming, currentStripeSubscriptionValue, file: file, line: line)
          XCTAssertEqual(plan, concurrentPlan, file: file, line: line)
          acceptedVersions.withValue { $0.append(snapshot.version) }
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
    XCTAssertEqual(
      validatedSubscriptions.value, [staleStripeSubscription, currentStripeSubscription],
      file: file, line: line
    )
    XCTAssertEqual(rejectedVersions.value, ["v1"], file: file, line: line)
    XCTAssertEqual(acceptedVersions.value, [concurrentVersion], file: file, line: line)
    XCTAssertEqual(store.value.subscription.plan, concurrentPlan, file: file, line: line)
    XCTAssertEqual(store.value.subscription.stripeSubscriptionStatus, .trialing, file: file, line: line)
    XCTAssertEqual(result.subscription.plan, concurrentPlan, file: file, line: line)
    XCTAssertEqual(result.stripeSubscription, currentStripeSubscription, file: file, line: line)
    XCTAssertEqual(
      operations.value,
      Array(repeating: ["snapshot", "stripe", "prices", "write"], count: 2).flatMap { $0 },
      file: file, line: line
    )
  }

  private func subscription(plan: Stripe.Plan) -> Stripe.Subscription {
    var subscription = Stripe.Subscription.mock
    subscription.plan = plan
    subscription.items.data[0].plan = plan
    return subscription
  }
}
