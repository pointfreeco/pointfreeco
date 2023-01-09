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

  return IO {
    var paymentMethod: PaymentMethod?
    if let paymentMethodID = subscription.customer.right?.invoiceSettings.defaultPaymentMethod {
      paymentMethod = try? await Current.stripe.fetchPaymentMethod(paymentMethodID)
    }
    return conn.map(const(paymentMethod .*. user .*. subscriberState .*. unit))
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

    let customer = subscription.customer.id

    return EitherIO {
      let paymentMethod = try await Current.stripe.attachPaymentMethod(paymentMethodID, customer)
      _ = try await Current.stripe.updateCustomer(customer, paymentMethod.id)
    }
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
