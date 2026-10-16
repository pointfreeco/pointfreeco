import Models
import PointFreeTestSupport
import StripeTestSupport
import XCTest

@testable import PointFree
@testable import Stripe

final class StripeMembershipPlanTests: TestCase {
  func testRecognizesCurrentMembershipPriceIDs() {
    let cases: [(Stripe.Plan, Pricing.Plan)] = [
      (.modernMaxYearly, .max),
      (.modernPersonalYearly, .pro),
      (.modernTeamYearly, .pro),
      (.modernPersonalMonthly, .pro),
    ]
    for (plan, expected) in cases {
      XCTAssertEqual(
        membershipPlan(for: subscription(plan: plan), prices: prices, productID: "prod_test"),
        expected
      )
    }
  }

  func testCanonicalLookupKeysCoverAllSupportedMembershipPrices() {
    XCTAssertEqual(
      Set(membershipPlanLookupKeys),
      Set<Stripe.Price.LookupKey>(["pointfree-max", "pointfree-pro", "pointfree-monthly"])
    )
    XCTAssertEqual(membershipPlanLookupKeys.count, 3)
  }

  func testCouponAndTrialDoNotChangeMembershipTier() {
    let cases: [(Stripe.Plan, Pricing.Plan)] = [
      (.modernMaxYearly, .max), (.modernPersonalYearly, .pro),
    ]
    for (plan, expected) in cases {
      var subscription = subscription(plan: plan)
      subscription.status = .trialing
      subscription.discount = .mock
      subscription.discount?.coupon.rate = .percentOff(100)
      subscription.discount?.coupon.name = "Free first year of Max"

      XCTAssertEqual(
        membershipPlan(for: subscription, prices: prices, productID: "prod_test"),
        expected
      )
    }
  }

  func testUsesItemsInsteadOfStaleTopLevelPlan() {
    var subscription = subscription(plan: .modernMaxYearly)
    subscription.plan = .modernPersonalYearly

    XCTAssertEqual(
      membershipPlan(for: subscription, prices: prices, productID: "prod_test"),
      .max
    )
  }

  func testRejectsNameMetadataAndPriceIDHeuristics() {
    var plan = Stripe.Plan.modernMaxYearly
    plan.id = "price_unrecognized_max"
    plan.nickname = "Point-Free Max"
    plan.metadata = ["plan": "max", "lookup_key": "pointfree-max"]

    XCTAssertNil(
      membershipPlan(for: subscription(plan: plan), prices: prices, productID: "prod_test")
    )
  }

  func testRejectsUnknownAndLegacyPriceIDs() {
    for plan in [Stripe.Plan.mock, .individualYearly] {
      XCTAssertNil(
        membershipPlan(for: subscription(plan: plan), prices: prices, productID: "prod_test")
      )
    }
  }

  func testRejectsUnknownAndMissingLookupKeysEvenWhenPriceIDMatches() {
    let lookupKeys: [Stripe.Price.LookupKey?] = [nil, "pointfree-max-preview"]
    for lookupKey in lookupKeys {
      var price = Stripe.Price.pointFreeMax
      price.lookupKey = lookupKey

      XCTAssertNil(
        membershipPlan(
          for: subscription(plan: .modernMaxYearly),
          prices: .mock([price]),
          productID: "prod_test"
        )
      )
    }
  }

  func testRejectsForeignProductOnSubscriptionItem() {
    var plan = Stripe.Plan.modernMaxYearly
    plan.product = "prod_unrelated"

    XCTAssertNil(
      membershipPlan(for: subscription(plan: plan), prices: prices, productID: "prod_test")
    )
  }

  func testRejectsMissingProductOnSubscriptionItem() {
    var plan = Stripe.Plan.modernMaxYearly
    plan.product = nil

    XCTAssertNil(
      membershipPlan(for: subscription(plan: plan), prices: prices, productID: "prod_test")
    )
  }

  func testRejectsForeignProductInPriceCatalog() {
    var price = Stripe.Price.pointFreeMax
    price.product = "prod_unrelated"

    XCTAssertNil(
      membershipPlan(
        for: subscription(plan: .modernMaxYearly),
        prices: .mock([price]),
        productID: "prod_test"
      )
    )
  }

  func testRejectsMixedMembershipItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.id = "si_pro"
    secondItem.plan = .modernPersonalYearly
    subscription.items.data.append(secondItem)

    XCTAssertNil(membershipPlan(for: subscription, prices: prices, productID: "prod_test"))
  }

  func testRejectsUnknownAdditionalPositiveQuantityItem() {
    var subscription = subscription(plan: .modernMaxYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.id = "si_unknown"
    subscription.items.data.append(secondItem)

    XCTAssertNil(membershipPlan(for: subscription, prices: prices, productID: "prod_test"))
  }

  func testAcceptsMultipleItemsOfTheSameMembershipTier() {
    var subscription = subscription(plan: .modernPersonalYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.id = "si_monthly"
    secondItem.plan = .modernPersonalMonthly
    secondItem.quantity = 3
    subscription.items.data.append(secondItem)

    XCTAssertEqual(
      membershipPlan(for: subscription, prices: prices, productID: "prod_test"),
      .pro
    )
  }

  func testIgnoresZeroQuantityItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    var secondItem = Stripe.Subscription.Item.mock
    secondItem.id = "si_unused"
    secondItem.quantity = 0
    subscription.items.data.append(secondItem)

    XCTAssertEqual(
      membershipPlan(for: subscription, prices: prices, productID: "prod_test"),
      .max
    )
  }

  func testRejectsSubscriptionsWithoutPositiveQuantityItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    subscription.items.data[0].quantity = 0

    XCTAssertNil(membershipPlan(for: subscription, prices: prices, productID: "prod_test"))

    subscription.items.data = []

    XCTAssertNil(membershipPlan(for: subscription, prices: prices, productID: "prod_test"))
  }

  func testRejectsTruncatedSubscriptionItems() {
    var subscription = subscription(plan: .modernMaxYearly)
    subscription.items.hasMore = true

    XCTAssertNil(membershipPlan(for: subscription, prices: prices, productID: "prod_test"))
  }

  func testRejectsTruncatedPriceCatalog() {
    var prices = self.prices
    prices.hasMore = true

    XCTAssertNil(
      membershipPlan(
        for: subscription(plan: .modernMaxYearly), prices: prices, productID: "prod_test"
      )
    )
  }

  func testRejectsEmptyPriceCatalog() {
    XCTAssertNil(
      membershipPlan(
        for: subscription(plan: .modernMaxYearly), prices: .mock([]), productID: "prod_test"
      )
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
