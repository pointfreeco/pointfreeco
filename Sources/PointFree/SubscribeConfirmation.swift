import Either
import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import Views

public let subscribeConfirmation
  : M<Tuple6<User?, Route, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon?>>
  = redirectActiveSubscribers(user: get1)
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: Views.subscriptionConfirmation,
      layoutData: { currentUser, currentRoute, subscriberState, lane, subscribeData, coupon in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (
            lane,
            subscribeData,
            coupon,
            currentUser,
            subscriberState,
            stats(forEpisodes: Current.episodes()),
            Current.stripe.js,
            Current.envVars.stripe.publishableKey
          ),
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
    }
)

public let discountSubscribeConfirmation
  = fetchAndValidateCoupon
    <| map(over6(Optional.some))
    >>> pure
    >=> subscribeConfirmation

private let fetchAndValidateCoupon
  : MT<
  Tuple6<User?, Route, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon.Id?>,
  Tuple6<User?, Route, SubscriberState, Pricing.Lane, SubscribeConfirmationData, Stripe.Coupon>
  >
  = filterMap(
    over6(fetchCoupon) >>> sequence6 >>> map(require6),
    or: redirect(
      to: .subscribeConfirmation(
        lane: .personal,
        billing: nil,
        isOwnerTakingSeat: nil,
        teammates: nil
      ),
      headersMiddleware: flash(.error, couponError)
    )
    )
    <<< filter(
      get6 >>> ^\.valid,
      or: redirect(
        to: .subscribeConfirmation(
          lane: .personal,
          billing: nil,
          isOwnerTakingSeat: nil,
          teammates: nil
        ),
        headersMiddleware: flash(.error, couponError)
      )
)

private let couponError = "That coupon code is invalid or has expired."

private func fetchCoupon(_ couponId: Stripe.Coupon.Id?) -> IO<Stripe.Coupon?> {
  guard let couponId = couponId else { return pure(nil) }
  return Current.stripe.fetchCoupon(couponId)
    .run
    .map(^\.right)
}

func redirectActiveSubscribers<A>(
  user: @escaping (A) -> User?
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      return { conn in
        let user = user(conn.data)

        let userSubscription = (user?.subscriptionId)
          .map { Current.database.fetchSubscriptionById($0).mapExcept(requireSome) }
          ?? throwE(unit)

        let ownerSubscription = (user?.id)
          .map { Current.database.fetchSubscriptionByOwnerId($0).mapExcept(requireSome) }
          ?? throwE(unit)

        let race = (userSubscription.run.parallel <|> ownerSubscription.run.parallel).sequential

        return EitherIO(run: race)
          .flatMap {
            $0.stripeSubscriptionStatus == .canceled
              ? throwE(unit as Error)
              : pure($0)
          }
          .run
          .flatMap(
            either(
              const(
                middleware(conn)
              ),
              const(
                conn
                  |> redirect(
                    to: .account(.index),
                    headersMiddleware: flash(.warning, "You already have an active subscription.")
                )
              )
            )
        )
      }
    }
}
