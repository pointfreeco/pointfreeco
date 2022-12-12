import Either
import EmailAddress
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tagged
import Tuple
import Views

func createApplePaymentIntent(
  _ conn: Conn<
    StatusLineOpen,
    Tuple6<User?, SiteRoute, SubscriberState, Pricing.Billing, PaymentMethod.ID, Int>
  >
) -> IO<Conn<ResponseEnded, Data>> {
  let (user, route, subscriberState, billing, paymentMethodID, quantity) = lower(conn.data)

  // TODO: create customer

  let customer = Current.stripe.createCustomer(
    .paymentMethod(paymentMethodID),
    nil,
    user?.email,
    nil,
    nil
  )
  .run
  .perform()
  dump(customer)

  let subscription = Current.stripe.createSubscription(
    customer.right!.id,
    billing.plan,
    quantity,
    nil //subscribeData.coupon ?? regionalDiscountCouponId
  )
    .run
    .perform()

  dump(billing.plan)
  dump(subscription)
  dump("---")

  fatalError()
}
