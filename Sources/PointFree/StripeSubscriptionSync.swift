import Database
import Dependencies
import EnvVars
import Logging
import LoggingDependencies
import Models
import Stripe

struct SynchronizedStripeSubscription {
  var stripeSubscription: Stripe.Subscription
  var subscription: Models.Subscription
}

enum SubscriptionSynchronizationError: Error {
  case concurrentModification
}

func synchronizeStripeSubscription(
  id: Stripe.Subscription.ID,
  validate: (Stripe.Subscription) throws -> Void = { _ in }
) async throws -> SynchronizedStripeSubscription {
  @Dependency(\.database) var database
  @Dependency(\.envVars.stripe.productId) var productID
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.logger) var logger
  @Dependency(\.stripe) var stripe

  for _ in 0..<3 {
    // Capture the row version BEFORE Stripe is read. Comparing only plan/status
    // misses an intervening Pro -> Max -> Pro change (the ABA problem).
    let snapshot = try await database.fetchSubscriptionSnapshot(id)
    let stripeSubscription = try await stripe.fetchSubscription(id)
    try validate(stripeSubscription)

    let plan: Pricing.Plan?
    do {
      let prices = try await stripe.fetchPricesForProduct(productID, membershipPlanLookupKeys)
      plan = membershipPlan(for: stripeSubscription, prices: prices, productID: productID)
    } catch {
      // Persist status even during a catalog outage, but do not overwrite a
      // newer row or acknowledge a webhook whose tier could not be reconciled.
      guard
        try await database.updateStripeSubscriptionIfUnchanged(
          stripeSubscription, nil, snapshot
        ) != nil
      else { continue }
      logger.log(
        .error,
        "Could not refresh the membership plan for Stripe subscription \(id): \(error)"
      )
      throw error
    }

    if plan == nil {
      // The catalog contains known current lookup keys, not every historical
      // price. Preserve retired/custom/ambiguous tiers and flag them for review.
      logger.log(
        .warning,
        "Unknown or ambiguous membership price for Stripe subscription \(id); retaining the stored plan."
      )
    }
    guard
      let subscription = try await database.updateStripeSubscriptionIfUnchanged(
        stripeSubscription, plan, snapshot
      )
    else {
      // Retry from a fresh local version AND a fresh Stripe response. Reusing
      // the response here could restore a tier that was just superseded.
      continue
    }

    if snapshot.subscription.plan == .max, subscription.plan == .pro {
      await fireAndForget {
        await removeBetaAccess(for: subscription)
      }
    }
    return SynchronizedStripeSubscription(
      stripeSubscription: stripeSubscription,
      subscription: subscription
    )
  }
  throw SubscriptionSynchronizationError.concurrentModification
}
