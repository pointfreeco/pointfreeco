import Dependencies
import Models
import PointFreeTestSupport
import StripeTestSupport
import XCTest

@testable import PointFree
@testable import Stripe

final class StripePricingTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
  }

  @MainActor
  func testResolvePlanIDKeepsCurrentPlanWhenIntervalUnchanged() async throws {
    struct UnexpectedFetch: Error {}

    let planID = try await withDependencies {
      $0.stripe.fetchPricesForProduct = { _, _ in
        throw UnexpectedFetch()
      }
    } operation: {
      try await resolvePlanID(
        for: Pricing(billing: .monthly, quantity: 8),
        currentSubscription: .teamMonthly
      )
    }

    XCTAssertEqual(planID, .legacyMonthly)
  }

  @MainActor
  func testResolvePlanIDReturnsModernPlanWhenIntervalChanges() async throws {
    let planID = try await withDependencies {
      $0.stripe.fetchPricesForProduct = { _, _ in
        .mock([.pointFreeMonthly, .pointFreePro])
      }
    } operation: {
      try await resolvePlanID(
        for: Pricing(billing: .yearly, quantity: 4),
        currentSubscription: .teamMonthly
      )
    }

    XCTAssertEqual(planID.rawValue, Price.pointFreePro.id.rawValue)
  }

  @MainActor
  func testResolvePlanIDUsesModernLookupKeyForNonGrandfatheredTeamSeatIncrease() async throws {
    var proItem = Subscription.Item.mock
    proItem.plan = .modernTeamYearly
    proItem.quantity = 3

    var currentSubscription = Subscription.teamYearly
    currentSubscription.plan = .modernTeamYearly
    currentSubscription.items = .mock([proItem])
    currentSubscription.quantity = 3

    let planID = try await withDependencies {
      $0.stripe.fetchPricesForProduct = { _, lookupKeys in
        XCTAssertEqual(lookupKeys, ["pointfree-pro"])
        return .mock([.pointFreePro])
      }
    } operation: {
      try await resolvePlanID(
        for: Pricing(billing: .yearly, quantity: 4),
        currentSubscription: currentSubscription
      )
    }

    XCTAssertEqual(planID.rawValue, Price.pointFreePro.id.rawValue)
  }

  @MainActor
  func testResolvePlanIDUsesMonthlyLookupKeyForPersonalMonthly() async throws {
    let planID = try await withDependencies {
      $0.stripe.fetchPricesForProduct = { _, lookupKeys in
        XCTAssertEqual(lookupKeys, ["pointfree-monthly"])
        return .mock([.pointFreeMonthly])
      }
    } operation: {
      try await resolvePlanID(for: Pricing(billing: .monthly, quantity: 1))
    }

    XCTAssertEqual(planID.rawValue, Price.pointFreeMonthly.id.rawValue)
  }

  @MainActor
  func testResolvePlanIDFailsForTeamMonthlyWithoutCurrentSubscription() async throws {
    do {
      _ = try await resolvePlanID(for: Pricing(billing: .monthly, quantity: 4))
      XCTFail("Expected team monthly pricing to be unavailable")
    } catch let error as PricingResolutionError {
      XCTAssertEqual(error, .missingModernPrice(Pricing(billing: .monthly, quantity: 4)))
    }
  }

  @MainActor
  func testResolvePlanIDFailsWhenModernPlanCannotBeFound() async throws {
    do {
      _ = try await withDependencies {
        $0.stripe.fetchPricesForProduct = { _, _ in
          .mock([.pointFreeMonthly])
        }
      } operation: {
        try await resolvePlanID(for: Pricing(billing: .yearly, quantity: 1))
      }
      XCTFail("Expected missing modern plan error")
    } catch let error as PricingResolutionError {
      XCTAssertEqual(
        error,
        .modernPriceNotFound(
          Pricing(billing: .yearly, quantity: 1),
          productID: "prod_test",
          lookupKey: "pointfree-pro"
        )
      )
    }
  }
}
