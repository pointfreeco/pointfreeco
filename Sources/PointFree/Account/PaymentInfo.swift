import Either
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import Views

let paymentInfoResponse =
  requireUserAndStripeSubscription
  <| writeStatus(.ok)
  >=> fetchPaymentMethod
  >=> map(lower)
  >>> respond(
    view: Views.paymentInfoView(paymentMethod:publishableKey:stripeJsSrc:),
    layoutData: { paymentMethod, currentUser, subscriberState in
      SimplePageLayoutData(
        currentSubscriberState: subscriberState,
        currentUser: currentUser,
        data: (paymentMethod, Current.envVars.stripe.publishableKey.rawValue, Current.stripe.js),
        title: "Update Payment Info"
      )
    }
  )

private let requireUserAndStripeSubscription:
  MT<Tuple2<User?, SubscriberState>, Tuple3<Stripe.Subscription, User, SubscriberState>> =
    filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription

private func fetchPaymentMethod<A>(
  conn: Conn<A, Tuple3<Stripe.Subscription, User, SubscriberState>>
) -> IO<Conn<A, Tuple3<PaymentMethod?, User, SubscriberState>>> {
  let (subscription, user, subscriberState) = lower(conn.data)

  if let paymentMethodID = subscription.customer.right?.invoiceSettings.defaultPaymentMethod {
    return Current.stripe.fetchPaymentMethod(paymentMethodID)
      .run
      .map(\.right)
      .map { conn.map(const($0 .*. user .*. subscriberState .*. unit)) }
  } else {
    return pure(conn.map(const(nil .*. user .*. subscriberState .*. unit)))
  }
}

private let genericPaymentInfoError = """
  We couldn’t update your payment info at this time. Please try again later or contact
  <support@pointfree.co>.
  """

let updatePaymentInfoMiddleware =
  requireUserAndPaymentMethod
  <<< requireStripeSubscription
  <| { conn in
    let (subscription, _, paymentMethodID) = lower(conn.data)

    let customer = subscription.customer.either(id, \.id)

    return Current.stripe.attachPaymentMethod(paymentMethodID, customer)
      .flatMap { Current.stripe.updateCustomer(customer, $0.id) }
      .run
      .flatMap {
        conn
          |> redirect(
            to: .account(.paymentInfo()),
            headersMiddleware: $0.isLeft
              ? flash(.error, genericPaymentInfoError)
              : flash(.notice, "Your payment information has been updated.")
          )
      }
  }

private let requireUserAndPaymentMethod:
  MT<Tuple2<User?, PaymentMethod.ID?>, Tuple2<User, PaymentMethod.ID>> =
    filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(
      require2 >>> pure,
      or: redirect(
        to: .account(.paymentInfo()),
        headersMiddleware: flash(.error, genericPaymentInfoError)
      )
    )
