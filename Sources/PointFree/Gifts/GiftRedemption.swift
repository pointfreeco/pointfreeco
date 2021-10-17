import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney
import Tuple
import Views

let giftRedemptionLandingMiddleware
: Middleware<StatusLineOpen, ResponseEnded, Tuple5<Coupon.Id, User?, Models.Subscription?, SubscriberState, Route>, Data>
= fetchAndValidateCouponAndGift
<| writeStatus(.ok)
>=> map(lower)
>>> respond(
  view: giftRedeemLanding(coupon:gift:subscriberState:currentUser:episodeStats:),
  layoutData: { coupon, gift, amount, user, subscription, subscriberState, route in
    SimplePageLayoutData(
      currentRoute: route,
      currentSubscriberState: subscriberState,
      currentUser: user,
      data: (coupon, gift, subscriberState, user, stats(forEpisodes: Current.episodes())),
      extraStyles: extraGiftLandingStyles <> testimonialStyle,
      style: .base(.some(.minimal(.black))),
      title: "Redeem your Point-Free gift"
    )
  }
)

let giftRedemptionMiddleware
: Middleware<StatusLineOpen, ResponseEnded, Tuple4<Coupon.Id, User?, Models.Subscription?, SubscriberState>, Data>
= fetchAndValidateCouponAndGift
<<< filterMap(require4 >>> pure, or: loginAndRedirect)
<| redeemGift

private func redeemGift(
_ conn: Conn<StatusLineOpen, Tuple6<Coupon, Gift, Cents<Int>, User, Models.Subscription?, SubscriberState>>
) -> IO<Conn<ResponseEnded, Data>> {
  let (coupon, gift, discount, user, subscription, subscriberState) = lower(conn.data)

  if let subscription = subscription, subscription.stripeSubscriptionStatus.isActive {
    guard subscriberState.isOwner
    else {
      return conn |> redirect(
        to: .gifts(.redeemLanding(coupon.id)),
        headersMiddleware: flash(
          .error,
          "You are already part of an active team subscription."
        )
      )
    }

    return Current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
      .flatMap { stripeSubscription -> EitherIO<Error, Customer> in
//        // TODO: Should we disallow gifts from applying to team subscriptions?
//        guard stripeSubscription.quantity == 1
//        else {
//
//        }

        return Current.stripe.updateCustomerBalance(
          stripeSubscription.customer.either(id, \.id),
          (stripeSubscription.customer.right?.balance ?? 0) + discount
        )
      }
      .run
      .flatMap { errorOrCustomer in
        switch errorOrCustomer {
        case .left:
          return conn |> redirect(
            to: .gifts(.redeemLanding(coupon.id)),
            headersMiddleware: flash(
              .error,
              """
              We were unable to redeem your gift. Please try again, or contact \
              <support@pointfree.co> for more help.
              """
            )
          )

        case .right:
          Current.stripe.deleteCoupon(coupon.id)
            .withExcept(notifyError(subject: "Error deleting coupon: \(coupon.id)"))
            .run
            .parallel
            .run { _ in }

          return conn |> redirect(
            to: .account(.index),
            headersMiddleware: flash(
              .notice,
              "The gift has been applied to your account as credit."
            )
          )
        }
      }
  } else {
    let plan: Plan.Id = gift.monthsFree < 12 ? .monthly : .yearly
    return Current.stripe.createCustomer(
      nil,
      user.id.rawValue.uuidString,
      user.email,
      nil,
      discount
    )
      .flatMap { customer in Current.stripe.createSubscription(customer.id, plan, 1, nil) }
      .run
      .flatMap { errorOrSubscription in
        switch errorOrSubscription {
        case .left:
          return conn |> redirect(
            to: .gifts(.redeemLanding(coupon.id)),
            headersMiddleware: flash(
              .error,
              """
              We were unable to redeem your gift. Please try again, or contact \
              <support@pointfree.co> for more help.
              """
            )
          )

        case .right:
          Current.stripe.deleteCoupon(coupon.id)
            .withExcept(notifyError(subject: "Error deleting coupon: \(coupon.id)"))
            .run
            .parallel
            .run { _ in }

          return conn |> redirect(
            to: .account(.index),
            headersMiddleware: flash(.notice, "You now have access to Point-Free!")
          )
        }
      }
  }
}

private func fetchAndValidateCouponAndGift<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T4<Coupon, Gift, Cents<Int>, A>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, T2<Coupon.Id, A>, Data> {

  return { conn in
    let (couponId, rest) = (conn.data.first, conn.data.second)
    return zip2(
      Current.stripe.fetchCoupon(couponId).run.parallel,
      Current.database.fetchGiftByStripeCouponId(couponId).run.parallel
    )
      .sequential
      .map { c, g in c.flatMap { c in g.map { g in (c, g) } } }
      .flatMap { errorOrCouponAndGift in
        switch errorOrCouponAndGift {
        case .left:
          return conn |> routeNotFoundMiddleware

        case let .right((coupon, gift)):
          guard coupon.valid
          else {
            return conn |> redirect(
              to: .gifts(.index),
              headersMiddleware: flash(.error, "This gift was already redeemed.")
            )
          }

          guard case let .amountOff(amount) = coupon.rate
          else {
            return conn |> redirect(
              to: .gifts(.redeemLanding(coupon.id)),
              headersMiddleware: flash(
                .error,
                """
                The gift is in an invalid state. Please contact <support@pointfree.co> for help \
                redeeming it.
                """
              )
            )
          }

          return conn.map(const(coupon .*. gift .*. amount .*. rest)) |> middleware
        }
      }
  }
}
