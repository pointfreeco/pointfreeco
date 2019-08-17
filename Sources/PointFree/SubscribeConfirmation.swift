import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import View
import Views

public let subscribeConfirmation: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple5<User?, Route, SubscriberState, Pricing.Lane, Stripe.Coupon?>,
  Data
  >
  = filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< redirectActiveSubscribers(user: get1)
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: View(Views.subscriptionConfirmation),
      layoutData: { currentUser, currentRoute, subscriberState, lane, coupon in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (
            lane,
            coupon,
            currentUser,
            Current.stripe.js,
            Current.envVars.stripe.publishableKey.rawValue
          ),
          extraStyles: extraSubscriptionLandingStyles,
          style: .base(.some(.minimal(.black))),
          title: "Subscribe to Point-Free"
        )
    }
)

public let discountSubscribeConfirmation: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple5<User?, Route, SubscriberState, Pricing.Lane, Stripe.Coupon.Id?>,
  Data
  >
  = filterMap(
    over5(fetchCoupon) >>> sequence5 >>> map(require5),
    or: redirect(to: .subscribeConfirmation(.personal), headersMiddleware: flash(.error, couponError))
    )
    <<< filter(
      get5 >>> ^\.valid,
      or: redirect(to: .subscribeConfirmation(.personal), headersMiddleware: flash(.error, couponError))
    )
    <| map(over5(Optional.some))
    >>> pure
    >=> subscribeConfirmation

private let couponError = "That coupon code is invalid or has expired."

private func fetchCoupon(_ couponId: Stripe.Coupon.Id?) -> IO<Stripe.Coupon?> {
  guard let couponId = couponId else { return pure(nil) }
  return Current.stripe.fetchCoupon(couponId)
    .run
    .map(^\.right)
}
