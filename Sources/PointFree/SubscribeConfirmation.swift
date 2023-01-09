import Dependencies
import Either
import EmailAddress
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import Views

public let subscribeConfirmation:
  M<
    Tuple6<
      User?, SiteRoute, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon?
    >
  > =
    validateReferralCode
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: Views.subscriptionConfirmation,
      layoutData: {
        (
          currentUser: User?,
          currentRoute: SiteRoute,
          subscriberState: SubscriberState,
          lane: Pricing.Lane,
          subscribeData: SubscribeConfirmationData,
          coupon: Stripe.Coupon?,
          referrer: User?
        ) in
        @Dependency(\.episodes) var episodes
        @Dependency(\.envVars) var envVars
        @Dependency(\.stripe.js) var js

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (
            lane,
            subscribeData,
            coupon,
            currentUser,
            subscriberState,
            referrer,
            stats(forEpisodes: episodes()),
            js,
            envVars.stripe.publishableKey
          ),
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: referrer == nil
            ? "Subscribe to Point-Free"
            : "Subscribe and get a free month of Point-Free"
        )
      }
    )

private func validateReferralCode(
  middleware: @escaping M<
    Tuple7<
      User?, SiteRoute, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon?,
      User?
    >
  >
) -> M<
  Tuple6<User?, SiteRoute, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon?>
> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  return { conn in
    let (currentUser, currentRoute, subscriberState, lane, subscribeData, coupon) = lower(conn.data)
    guard
      let referralCode = subscribeData.referralCode
    else {
      return middleware(
        conn.map(
          const(
            currentUser
              .*. currentRoute
              .*. subscriberState
              .*. lane
              .*. subscribeData
              .*. coupon
              .*. nil
              .*. unit
          )
        )
      )
    }

    guard lane == .personal else {
      return conn
        |> redirect(
          to: .subscribeConfirmation(
            lane: lane,
            billing: subscribeData.billing,
            isOwnerTakingSeat: subscribeData.isOwnerTakingSeat,
            teammates: subscribeData.teammates,
            useRegionalDiscount: subscribeData.useRegionalDiscount
          ),
          headersMiddleware: flash(.error, "Referrals are only valid for personal subscriptions.")
        )
    }

    guard currentUser?.referrerId == nil else {
      return conn
        |> redirect(
          to: .subscribeConfirmation(
            lane: lane,
            billing: subscribeData.billing,
            isOwnerTakingSeat: subscribeData.isOwnerTakingSeat,
            teammates: subscribeData.teammates,
            useRegionalDiscount: subscribeData.useRegionalDiscount
          ),
          headersMiddleware: flash(.error, "Referrals are only valid for first-time subscribers.")
        )
    }

    if let coupon = coupon {
      return conn |> redirect(to: .discounts(code: coupon.id, subscribeData.billing))
    }

    return EitherIO {
      let referrer = try await database.fetchUserByReferralCode(referralCode)
      let subscription = try await database.fetchSubscriptionByOwnerId(referrer.id)
      let stripeSubscription = try await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      guard stripeSubscription.isCancellable else { throw unit }
      return referrer
    }
    .run
    .flatMap(
      either(
        const(
          conn
            |> redirect(
              to: .subscribeConfirmation(
                lane: lane,
                billing: subscribeData.billing,
                isOwnerTakingSeat: subscribeData.isOwnerTakingSeat,
                teammates: subscribeData.teammates,
                useRegionalDiscount: subscribeData.useRegionalDiscount
              ),
              headersMiddleware: flash(.error, "Invalid referral code.")
            )
        ),
        { referrer in
          conn.map(
            const(
              currentUser
                .*. currentRoute
                .*. subscriberState
                .*. lane
                .*. subscribeData
                .*. coupon
                .*. referrer
                .*. unit
            )
          ) |> middleware
        }
      )
    )
  }
}

public let discountSubscribeConfirmation =
  fetchAndValidateCoupon
  <| map(over6(Optional.some))
  >>> pure
  >=> subscribeConfirmation

private let fetchAndValidateCoupon:
  MT<
    Tuple6<
      User?, SiteRoute, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon.ID?
    >,
    Tuple6<
      User?, SiteRoute, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon
    >
  > =
    filterMap(
      over6(fetchCoupon) >>> sequence6 >>> map(require6),
      or: redirect(
        to: .subscribeConfirmation(
          lane: .personal,
          useRegionalDiscount: false
        ),
        headersMiddleware: flash(.error, couponError)
      )
    )
    <<< filter(
      get6 >>> \.valid,
      or: redirect(
        to: .subscribeConfirmation(
          lane: .personal,
          useRegionalDiscount: false
        ),
        headersMiddleware: flash(.error, couponError)
      )
    )

private let couponError = "That coupon code is invalid or has expired."

private func fetchCoupon(_ couponId: Stripe.Coupon.ID?) -> IO<Stripe.Coupon?> {
  return IO {
    @Dependency(\.envVars) var envVars
    @Dependency(\.stripe) var stripe
    guard let couponId, couponId != envVars.regionalDiscountCouponId else { return nil }
    return try? await stripe.fetchCoupon(couponId)
  }
}

func redirectActiveSubscribers<A>(
  user: @escaping (A) -> User?
)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data>
{
  @Dependency(\.database) var database

  return { middleware in
    return { conn in
      let user = user(conn.data)

      return EitherIO {
        let subscription = try await database.fetchSubscription(user: user.unwrap())
        guard subscription.stripeSubscriptionStatus != .canceled
        else { throw unit }
        return subscription
      }
      .run
      .flatMap {
        $0.either(
          { _ in
            middleware(conn)
          },
          { _ in
            conn
              |> redirect(
                to: .account(),
                headersMiddleware: flash(.warning, "You already have an active subscription.")
              )
          }
        )
      }
    }
  }
}
