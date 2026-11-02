import Database
import Dependencies
import Foundation
import Models
import PointFreeTestSupport
import Stripe
import StripeTestSupport
import XCTest

final class SubscriptionSnapshotTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  func testSnapshotDecodesStoredSubscriptionAndVersion() async throws {
    let (stripeSubscription, subscription) = try await createSubscription(plan: .max)

    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    let repeatedSnapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)

    XCTAssertEqual(snapshot.subscription.id, subscription.id)
    XCTAssertEqual(snapshot.subscription.userId, subscription.userId)
    XCTAssertEqual(snapshot.subscription.stripeSubscriptionId, stripeSubscription.id)
    XCTAssertEqual(snapshot.subscription.stripeSubscriptionStatus, .active)
    XCTAssertEqual(snapshot.subscription.plan, .max)
    XCTAssertEqual(snapshot.subscription.deactivated, subscription.deactivated)
    XCTAssertEqual(snapshot.subscription.teamInviteCode, subscription.teamInviteCode)
    XCTAssertFalse(snapshot.version.isEmpty)
    XCTAssertEqual(snapshot.version, repeatedSnapshot.version)
  }

  func testConditionalUpdateStoresStatusAndPlanAndAdvancesVersion() async throws {
    let (initialStripeSubscription, subscription) = try await createSubscription()
    var stripeSubscription = initialStripeSubscription
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    stripeSubscription.status = .trialing

    let result = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .max, snapshot
    )
    let updated = try XCTUnwrap(result)
    let nextSnapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)

    XCTAssertEqual(updated.id, subscription.id)
    XCTAssertEqual(updated.plan, .max)
    XCTAssertEqual(updated.stripeSubscriptionStatus, .trialing)
    XCTAssertEqual(nextSnapshot.subscription.plan, .max)
    XCTAssertEqual(nextSnapshot.subscription.stripeSubscriptionStatus, .trialing)
    XCTAssertNotEqual(snapshot.version, nextSnapshot.version)
  }

  func testRejectsSnapshotAfterIndependentStatusWrite() async throws {
    let (stripeSubscription, subscription) = try await createSubscription()
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    var canceledSubscription = stripeSubscription
    canceledSubscription.status = .canceled
    _ = try await database.updateStripeSubscription(canceledSubscription)

    let result = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .max, snapshot
    )
    let persisted = try await database.fetchSubscription(id: subscription.id)

    XCTAssertNil(result)
    XCTAssertEqual(persisted.plan, .pro)
    XCTAssertEqual(persisted.stripeSubscriptionStatus, .canceled)
  }

  func testRejectsSnapshotAfterIndependentPlanWrite() async throws {
    let (initialStripeSubscription, subscription) = try await createSubscription()
    var stripeSubscription = initialStripeSubscription
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    try await database.updateSubscriptionPlan(subscription.id, .max)
    stripeSubscription.status = .pastDue

    let result = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .pro, snapshot
    )
    let persisted = try await database.fetchSubscription(id: subscription.id)

    XCTAssertNil(result)
    XCTAssertEqual(persisted.plan, .max)
    XCTAssertEqual(persisted.stripeSubscriptionStatus, .active)
  }

  func testRejectsABAAfterPlanReturnsToOriginalValue() async throws {
    let (stripeSubscription, subscription) = try await createSubscription()
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    try await database.updateSubscriptionPlan(subscription.id, .max)
    try await database.updateSubscriptionPlan(subscription.id, .pro)
    let currentSnapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)

    XCTAssertEqual(currentSnapshot.subscription.plan, snapshot.subscription.plan)
    XCTAssertEqual(
      currentSnapshot.subscription.stripeSubscriptionStatus,
      snapshot.subscription.stripeSubscriptionStatus
    )
    XCTAssertNotEqual(currentSnapshot.version, snapshot.version)

    let result = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .max, snapshot
    )
    let persisted = try await database.fetchSubscription(id: subscription.id)

    XCTAssertNil(result)
    XCTAssertEqual(persisted.plan, .pro)
    XCTAssertEqual(persisted.stripeSubscriptionStatus, .active)
  }

  func testUnknownTierUpdatesStatusWithoutChangingExistingPlan() async throws {
    let (initialStripeSubscription, subscription) = try await createSubscription(plan: .max)
    var stripeSubscription = initialStripeSubscription
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    stripeSubscription.status = .pastDue

    let result = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, nil, snapshot
    )
    let updated = try XCTUnwrap(result)
    let persisted = try await database.fetchSubscription(id: subscription.id)
    let nextSnapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)

    XCTAssertEqual(updated.plan, .max)
    XCTAssertEqual(updated.stripeSubscriptionStatus, .pastDue)
    XCTAssertEqual(persisted.plan, .max)
    XCTAssertEqual(persisted.stripeSubscriptionStatus, .pastDue)
    XCTAssertNotEqual(nextSnapshot.version, snapshot.version)
  }

  func testUnknownTierCannotOverwriteStatusAfterVersionConflict() async throws {
    let (initialStripeSubscription, subscription) = try await createSubscription()
    var stripeSubscription = initialStripeSubscription
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    try await database.updateSubscriptionPlan(subscription.id, .max)
    stripeSubscription.status = .pastDue

    let result = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, nil, snapshot
    )
    let persisted = try await database.fetchSubscription(id: subscription.id)

    XCTAssertNil(result)
    XCTAssertEqual(persisted.plan, .max)
    XCTAssertEqual(persisted.stripeSubscriptionStatus, .active)
  }

  func testNoOpUpdateStillConsumesSnapshotVersion() async throws {
    let (stripeSubscription, _) = try await createSubscription()
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)

    let firstResult = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, nil, snapshot
    )
    let staleResult = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .max, snapshot
    )
    let freshSnapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    let freshResult = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .max, freshSnapshot
    )

    XCTAssertNotNil(firstResult)
    XCTAssertNil(staleResult)
    XCTAssertNotEqual(freshSnapshot.version, snapshot.version)
    XCTAssertEqual(try XCTUnwrap(freshResult).plan, .max)
  }

  func testMismatchedStripeSubscriptionIDCannotUpdateSnapshotRow() async throws {
    let (initialStripeSubscription, subscription) = try await createSubscription()
    var stripeSubscription = initialStripeSubscription
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    stripeSubscription.id = "sub_other"
    stripeSubscription.status = .canceled

    let result = try await database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .max, snapshot
    )
    let persisted = try await database.fetchSubscription(id: subscription.id)

    XCTAssertNil(result)
    XCTAssertEqual(persisted.plan, .pro)
    XCTAssertEqual(persisted.stripeSubscriptionStatus, .active)
    XCTAssertEqual(persisted.stripeSubscriptionId, snapshot.subscription.stripeSubscriptionId)
  }

  func testCompetingConditionalUpdatesAllowOnlyOneWinner() async throws {
    let (stripeSubscription, subscription) = try await createSubscription()
    let snapshot = try await database.fetchSubscriptionSnapshot(stripeSubscription.id)
    var pastDueSubscription = stripeSubscription
    pastDueSubscription.status = .pastDue
    let pastDueSubscriptionValue = pastDueSubscription

    async let first = database.updateStripeSubscriptionIfUnchanged(
      stripeSubscription, .max, snapshot
    )
    async let second = database.updateStripeSubscriptionIfUnchanged(
      pastDueSubscriptionValue, .pro, snapshot
    )
    let (firstResult, secondResult) = try await (first, second)
    let winners = [firstResult, secondResult].compactMap { $0 }
    XCTAssertEqual(winners.count, 1)
    let winner = try XCTUnwrap(winners.first)
    let persisted = try await database.fetchSubscription(id: subscription.id)

    XCTAssertEqual(persisted.plan, winner.plan)
    XCTAssertEqual(persisted.stripeSubscriptionStatus, winner.stripeSubscriptionStatus)
  }

  private func createSubscription(
    plan: Pricing.Plan = .pro
  ) async throws -> (Stripe.Subscription, Models.Subscription) {
    let user = try await database.registerUser(
      accessToken: nil,
      gitHubUser: nil,
      email: "snapshot-tests@pointfree.co",
      now: { Date(timeIntervalSince1970: 1_500_000_000) }
    )
    var stripeSubscription = Stripe.Subscription.mock
    stripeSubscription.id = "sub_snapshot_test"
    let subscription = try await database.createSubscription(
      stripeSubscription, user.id, true, nil, plan
    )
    return (stripeSubscription, subscription)
  }
}
