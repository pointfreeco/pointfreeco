import CustomDump
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
        for: Pricing(plan: .pro, billing: .monthly, quantity: 8),
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
        for: Pricing(plan: .pro, billing: .yearly, quantity: 4),
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
        for: Pricing(plan: .pro, billing: .yearly, quantity: 4),
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
      try await resolvePlanID(for: Pricing(plan: .pro, billing: .monthly, quantity: 1))
    }

    XCTAssertEqual(planID.rawValue, Price.pointFreeMonthly.id.rawValue)
  }

  @MainActor
  func testResolvePlanIDFailsForTeamMonthlyWithoutCurrentSubscription() async throws {
    do {
      _ = try await resolvePlanID(for: Pricing(plan: .pro, billing: .monthly, quantity: 4))
      XCTFail("Expected team monthly pricing to be unavailable")
    } catch let error as PricingResolutionError {
      XCTAssertEqual(error, .missingModernPrice(Pricing(plan: .pro, billing: .monthly, quantity: 4)))
    }
  }

  @MainActor
  func testResolvePlanIDUsesMaxLookupKeyForPersonalMax() async throws {
    let planID = try await withDependencies {
      $0.stripe.fetchPricesForProduct = { _, lookupKeys in
        XCTAssertEqual(lookupKeys, ["pointfree-max"])
        return .mock([.pointFreeMax])
      }
    } operation: {
      try await resolvePlanID(for: Pricing(plan: .max, billing: .yearly, quantity: 1))
    }

    XCTAssertEqual(planID.rawValue, Price.pointFreeMax.id.rawValue)
  }

  @MainActor
  func testResolvePlanIDUsesMaxLookupKeyForTeamMax() async throws {
    let planID = try await withDependencies {
      $0.stripe.fetchPricesForProduct = { _, lookupKeys in
        XCTAssertEqual(lookupKeys, ["pointfree-max"])
        return .mock([.pointFreeMax])
      }
    } operation: {
      try await resolvePlanID(for: Pricing(plan: .max, billing: .yearly, quantity: 4))
    }

    XCTAssertEqual(planID.rawValue, Price.pointFreeMax.id.rawValue)
  }

  @MainActor
  func testResolvePlanIDResolvesMaxWhenProSubscriberUpgradesOnSameInterval() async throws {
    let planID = try await withDependencies {
      $0.stripe.fetchPricesForProduct = { _, lookupKeys in
        XCTAssertEqual(lookupKeys, ["pointfree-max"])
        return .mock([.pointFreeMax])
      }
    } operation: {
      try await resolvePlanID(
        for: Pricing(plan: .max, billing: .yearly, quantity: 1),
        currentSubscription: .individualYearly
      )
    }

    XCTAssertEqual(planID.rawValue, Price.pointFreeMax.id.rawValue)
  }

  @MainActor
  func testResolvePlanIDFailsWhenModernPlanCannotBeFound() async throws {
    do {
      _ = try await withDependencies {
        $0.stripe.fetchPricesForProduct = { _, _ in
          .mock([.pointFreeMonthly])
        }
      } operation: {
        try await resolvePlanID(for: Pricing(plan: .pro, billing: .yearly, quantity: 1))
      }
      XCTFail("Expected missing modern plan error")
    } catch let error as PricingResolutionError {
      XCTAssertEqual(
        error,
        .modernPriceNotFound(
          Pricing(plan: .pro, billing: .yearly, quantity: 1),
          productID: "prod_test",
          lookupKey: "pointfree-pro"
        )
      )
    }
  }

  func testRecognizesCurrentMembershipPriceIDs() {
    for plan in [Stripe.Plan.modernPersonalYearly, .modernTeamYearly, .modernPersonalMonthly] {
      assertPlan(.pro, for: subscription(plan: plan))
    }
    assertPlan(.max, for: subscription(plan: .modernMaxYearly))
  }

  func testCanonicalLookupKeysCoverAllSupportedMembershipPrices() {
    expectNoDifference(
      membershipPlanLookupKeys, ["pointfree-max", "pointfree-monthly", "pointfree-pro"])
  }

  func testCouponAndTrialDoNotChangeMembershipTier() {
    for (plan, expected) in [
      (Stripe.Plan.modernMaxYearly, Pricing.Plan.max), (.modernPersonalYearly, .pro),
    ] {
      var subscription = subscription(plan: plan)
      subscription.status = .trialing
      subscription.discount = .mock
      subscription.discount?.coupon.rate = .percentOff(100)
      subscription.discount?.coupon.name = "Free first year of Max"
      assertPlan(expected, for: subscription)
    }
  }

  func testUsesItemsInsteadOfStaleTopLevelPlan() {
    var subscription = subscription(plan: .modernMaxYearly)
    subscription.plan = .modernPersonalYearly
    assertPlan(.max, for: subscription)
  }

  func testRejectsNameMetadataAndPriceIDHeuristics() {
    var plan = Stripe.Plan.modernMaxYearly
    plan.id = "price_unrecognized_max"
    plan.nickname = "Point-Free Max"
    plan.metadata = ["plan": "max", "lookup_key": "pointfree-max"]
    assertPlan(nil, for: subscription(plan: plan))
  }

  func testRejectsUnknownAndLegacyPriceIDs() {
    for plan in [Stripe.Plan.mock, .individualYearly] {
      assertPlan(nil, for: subscription(plan: plan))
    }
  }

  func testRejectsUnknownAndMissingLookupKeysEvenWhenPriceIDMatches() {
    for lookupKey: Stripe.Price.LookupKey? in [nil, "pointfree-max-preview"] {
      var price = Stripe.Price.pointFreeMax
      price.lookupKey = lookupKey
      assertPlan(nil, for: subscription(plan: .modernMaxYearly), prices: .mock([price]))
    }
  }

  func testRejectsForeignProductOnSubscriptionItem() {
    var plan = Stripe.Plan.modernMaxYearly
    plan.product = "prod_unrelated"
    assertPlan(nil, for: subscription(plan: plan))
  }

  func testRejectsMissingProductOnSubscriptionItem() {
    var plan = Stripe.Plan.modernMaxYearly
    plan.product = nil
    assertPlan(nil, for: subscription(plan: plan))
  }

  func testRejectsForeignProductInPriceCatalog() {
    var price = Stripe.Price.pointFreeMax
    price.product = "prod_unrelated"
    assertPlan(nil, for: subscription(plan: .modernMaxYearly), prices: .mock([price]))
  }

  func testRejectsMixedMembershipItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.id = "si_pro"
    secondItem.plan = .modernPersonalYearly
    subscription.items.data.append(secondItem)
    assertPlan(nil, for: subscription)
  }

  func testRejectsUnknownAdditionalPositiveQuantityItem() {
    var subscription = subscription(plan: .modernMaxYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.id = "si_unknown"
    subscription.items.data.append(secondItem)
    assertPlan(nil, for: subscription)
  }

  func testAcceptsMultipleItemsOfTheSameMembershipTier() {
    var subscription = subscription(plan: .modernPersonalYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.id = "si_monthly"
    secondItem.plan = .modernPersonalMonthly
    secondItem.quantity = 3
    subscription.items.data.append(secondItem)
    assertPlan(.pro, for: subscription)
  }

  func testIgnoresZeroQuantityItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.quantity = 0
    subscription.items.data.append(secondItem)
    assertPlan(.max, for: subscription)
  }

  func testRejectsSubscriptionsWithoutPositiveQuantityItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    subscription.items.data[0].quantity = 0
    assertPlan(nil, for: subscription)
    subscription.items.data = []
    assertPlan(nil, for: subscription)
  }

  func testRejectsTruncatedSubscriptionItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    subscription.items.hasMore = true
    assertPlan(nil, for: subscription)
  }

  func testRejectsTruncatedPriceCatalog() {
    var prices = self.prices
    prices.hasMore = true
    assertPlan(nil, for: subscription(plan: .modernMaxYearly), prices: prices)
  }

  func testRejectsEmptyPriceCatalog() {
    assertPlan(nil, for: subscription(plan: .modernMaxYearly), prices: .mock([]))
  }

  private func assertPlan(
    _ expected: Pricing.Plan?,
    for subscription: Stripe.Subscription,
    prices: Stripe.ListEnvelope<Stripe.Price>? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    expectNoDifference(
      membershipPlan(for: subscription, prices: prices ?? self.prices, productID: "prod_test"),
      expected, filePath: file, line: line
    )
  }

  private var prices: Stripe.ListEnvelope<Stripe.Price> {
    .mock([.pointFreeMonthly, .pointFreePro, .pointFreeMax])
  }

  private func subscription(plan: Stripe.Plan) -> Stripe.Subscription {
    var subscription = Stripe.Subscription.mock
    subscription.plan = plan
    subscription.items.data[0].plan = plan
    return subscription
  }
}
