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
