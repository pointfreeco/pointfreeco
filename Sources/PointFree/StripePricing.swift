import Dependencies
import EnvVars
import Models
import Stripe
import TaggedMoney

enum PricingResolutionError: Error, Equatable {
  case missingModernPrice(Pricing)
  case modernPriceNotFound(Pricing, productID: Stripe.Product.ID, lookupKey: Stripe.Price.LookupKey)
}

func resolvePrice(
  for pricing: Pricing
) async throws -> Stripe.Price {
  @Dependency(\.envVars) var envVars
  @Dependency(\.stripe) var stripe

  let lookupKey = try modernLookupKey(for: pricing)
  let prices = try await stripe
    .fetchPricesForProduct(envVars.stripe.productId, [lookupKey])
    .data

  guard
    let price = prices.first(where: {
      $0.lookupKey == lookupKey
      && $0.product == envVars.stripe.productId
    })
  else {
    throw PricingResolutionError.modernPriceNotFound(
      pricing,
      productID: envVars.stripe.productId,
      lookupKey: lookupKey
    )
  }

  return price
}

func resolvePlanID(
  for pricing: Pricing,
  currentSubscription: Stripe.Subscription? = nil
) async throws -> Stripe.Plan.ID {
  let price = try await resolvePrice(for: pricing)
  return Stripe.Plan.ID(rawValue: price.id.rawValue)
}

func isModernPricingPlan(_ plan: Stripe.Plan, envVars: EnvVars) -> Bool {
  plan.product == envVars.stripe.productId
}

private func modernLookupKey(for pricing: Pricing) throws -> Stripe.Price.LookupKey {
  switch (pricing.plan, pricing.lane, pricing.billing) {
  case (.max, _, .monthly), (.pro, .team, .monthly):
    throw PricingResolutionError.missingModernPrice(pricing)
  case (.max, _, .yearly):
    "pointfree-max"
  case (.pro, .personal, .monthly):
    "pointfree-monthly"
  case (.pro, _, .yearly):
    "pointfree-pro"
  }
}

private let membershipPlansByLookupKey: [Stripe.Price.LookupKey: Pricing.Plan] = Dictionary(
  uniqueKeysWithValues: Pricing.Plan.allCases.flatMap { plan in
    Pricing.Billing.allCases.compactMap { billing -> (Stripe.Price.LookupKey, Pricing.Plan)? in
      guard let lookupKey = try? modernLookupKey(
        for: Pricing(plan: plan, billing: billing, quantity: 1)
      ) else { return nil }
      return (lookupKey, plan)
    }
  }
)

let membershipPlanLookupKeys = membershipPlansByLookupKey.keys.sorted {
  $0.rawValue < $1.rawValue
}

func membershipPlan(
  for subscription: Stripe.Subscription,
  prices: Stripe.ListEnvelope<Stripe.Price>,
  productID: Stripe.Product.ID
) -> Pricing.Plan? {
  guard !subscription.items.hasMore, !prices.hasMore else { return nil }
  let items = subscription.items.data.filter { $0.quantity > 0 }
  guard !items.isEmpty else { return nil }

  var resolvedPlan: Pricing.Plan?
  for item in items {
    guard
      item.plan.product == productID,
      let price = prices.data.first(where: {
        $0.id.rawValue == item.plan.id.rawValue && $0.product == productID
      }),
      let lookupKey = price.lookupKey,
      let plan = membershipPlansByLookupKey[lookupKey]
    else { return nil }

    // A subscription has one shared entitlement. Do not guess how mixed tiers
    // should apply to its owner and teammates.
    guard resolvedPlan == nil || resolvedPlan == plan else { return nil }
    resolvedPlan = plan
  }
  return resolvedPlan
}
