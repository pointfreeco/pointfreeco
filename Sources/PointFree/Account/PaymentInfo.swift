import Either
import Foundation
import HttpPipeline
import Models
import Optics
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import Views

let paymentInfoResponse =
  requireUserAndStripeSubscription
    <<< requirePaymentInfo
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: Views.paymentInfoView(card:publishableKey:stripeJsSrc:),
      layoutData: { card, currentUser, subscriberState in
        SimplePageLayoutData(
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (card, Current.envVars.stripe.publishableKey.rawValue, Current.stripe.js),
          title: "Update Payment Info"
        )
    }
)

private let requireUserAndStripeSubscription
  : MT<Tuple2<User?, SubscriberState>, Tuple3<Stripe.Subscription, User, SubscriberState>>
  = filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription

private let requirePaymentInfo
  : MT<
  Tuple3<Stripe.Subscription, User, SubscriberState>,
  Tuple3<Card, User, SubscriberState>
  >
  = filterMap(
    over1(^\.customer.right?.sources.data.first?.left) >>> require1 >>> pure,
    or: redirect(
      to: .account(.index),
      headersMiddleware: flash(
        .error,
        "You have invoice billing. Contact us <support@pointfree.co> to make changes to your payment info."
      )
    )
)

private let genericPaymentInfoError = """
We couldn’t update your payment info at this time. Please try again later or contact
<support@pointfree.co>.
"""

let updatePaymentInfoMiddleware
  = requireUserAndToken
    <<< requireStripeSubscription
    <| { conn in
      let (subscription, _, token) = lower(conn.data)

      return Current.stripe.updateCustomer(subscription.customer.either(id, ^\.id), token)
        .run
        .flatMap {
          conn |> redirect(
            to: .account(.paymentInfo(.show)),
            headersMiddleware: $0.isLeft
              ? flash(.error, genericPaymentInfoError)
              : flash(.notice, "Your payment information has been updated.")
          )
      }
}

private let requireUserAndToken
  : MT<Tuple2<User?, Stripe.Token.Id?>, Tuple2<User, Stripe.Token.Id>>
  = filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(
      require2 >>> pure,
      or: redirect(
        to: .account(.paymentInfo(.show)),
        headersMiddleware: flash(.error, genericPaymentInfoError)
      )
)
