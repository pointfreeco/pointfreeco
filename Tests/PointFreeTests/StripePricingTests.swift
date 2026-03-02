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
      $0.stripe.fetchPlansForProduct = { _ in
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
      $0.stripe.fetchPlansForProduct = { _ in
        .mock([.modernPersonalMonthly, .modernPersonalYearly, .modernTeamYearly])
      }
    } operation: {
      try await resolvePlanID(
        for: Pricing(billing: .yearly, quantity: 4),
        currentSubscription: .teamMonthly
      )
    }

    XCTAssertEqual(planID, Plan.modernTeamYearly.id)
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
        $0.stripe.fetchPlansForProduct = { _ in
          .mock([.modernPersonalMonthly])
        }
      } operation: {
        try await resolvePlanID(for: Pricing(billing: .yearly, quantity: 1))
      }
      XCTFail("Expected missing modern plan error")
    } catch let error as PricingResolutionError {
      XCTAssertEqual(
        error,
        .modernPlanNotFound(
          Pricing(billing: .yearly, quantity: 1),
          productID: "prod_test"
        )
      )
    }
  }
}
