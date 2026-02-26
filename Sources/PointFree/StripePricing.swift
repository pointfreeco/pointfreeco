import Dependencies
import EnvVars
import Models
import Stripe
import TaggedMoney

enum PricingResolutionError: Error, Equatable {
  case missingModernPrice(Pricing)
  case modernPriceNotFound(Pricing, productID: Stripe.Product.ID, lookupKey: Stripe.Price.LookupKey)
}

func resolvePlanID(
  for pricing: Pricing,
  currentSubscription: Stripe.Subscription? = nil
) async throws -> Stripe.Plan.ID {
  @Dependency(\.envVars) var envVars
  @Dependency(\.stripe) var stripe

  if let currentSubscription, currentSubscription.plan.interval == pricing.interval {
    return currentSubscription.plan.id
  }

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

  return .init(rawValue: price.id.rawValue)
}

func isModernPricingPlan(_ plan: Stripe.Plan, envVars: EnvVars) -> Bool {
  plan.product == envVars.stripe.productId
}

private func modernLookupKey(for pricing: Pricing) throws -> Stripe.Price.LookupKey {
  switch (pricing.lane, pricing.billing) {
  case (.personal, .monthly):
    "pointfree-monthly"
  case (.personal, .yearly), (.team, .yearly):
    "pointfree-pro"
  case (.team, .monthly):
    throw PricingResolutionError.missingModernPrice(pricing)
  }
}
