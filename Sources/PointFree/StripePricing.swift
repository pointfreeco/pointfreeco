import Dependencies
import EnvVars
import Models
import Stripe
import TaggedMoney

enum PricingResolutionError: Error, Equatable {
  case missingModernPrice(Pricing)
  case modernPlanNotFound(Pricing, productID: Stripe.Product.ID)
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

  guard let modernPrice = pricing.modernPricing
  else { throw PricingResolutionError.missingModernPrice(pricing) }

  let plans = try await stripe.fetchPlansForProduct(envVars.stripe.pricingProductId).data

  guard
    let plan = plans.first(where: {
      $0.interval == pricing.interval
        && $0.amount == modernPrice
    })
  else {
    throw PricingResolutionError.modernPlanNotFound(pricing, productID: envVars.stripe.pricingProductId)
  }

  return plan.id
}

func isModernPricingPlan(_ plan: Stripe.Plan, envVars: EnvVars) -> Bool {
  plan.product == envVars.stripe.pricingProductId
}
