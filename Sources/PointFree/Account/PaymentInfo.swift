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
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< filterMap(
      over1(\.customer.right?.sources.data.first?.left) >>> require1 >>> pure,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(
          .error,
          "You have invoice billing. Contact us <support@pointfree.co> to make changes to your payment info."
        )
      )
    )
    <| writeStatus(.ok)
    >=> map(lower)
    >>> _respond(
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

private let genericPaymentInfoError = """
We couldn’t update your payment info at this time. Please try again later or contact
<support@pointfree.co>.
"""

let updatePaymentInfoMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple2<User?, Stripe.Token.Id?>, Data> =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(
      require2 >>> pure,
      or: redirect(
        to: .account(.paymentInfo(.show)),
        headersMiddleware: flash(.error, genericPaymentInfoError)
      )
    )
    <<< requireStripeSubscription
    <| { conn in
      let (subscription, _, token) = lower(conn.data)

      return Current.stripe.updateCustomer(subscription.customer.either(id, \.id), token)
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
