import CustomDump
import Models
import PointFreeTestSupport
import StripeTestSupport
import XCTest

@testable import PointFree
@testable import Stripe

final class StripeMembershipPlanTests: TestCase {
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
