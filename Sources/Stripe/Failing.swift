import PointFreePrelude
import XCTestDynamicOverlay

extension Client {
  public static let failing = Self(
    attachPaymentMethod: unimplemented("Stripe.Client.attachPaymentMethod"),
    cancelSubscription: unimplemented("Stripe.Client.cancelSubscription"),
    confirmPaymentIntent: unimplemented("Stripe.Client.confirmPaymentIntent"),
    createCoupon: unimplemented("Stripe.Client.createCoupon"),
    createCustomer: unimplemented("Stripe.Client.createCustomer"),
    createPaymentIntent: unimplemented("Stripe.Client.createPaymentIntent"),
    createSubscription: unimplemented("Stripe.Client.createSubscription"),
    deleteCoupon: unimplemented("Stripe.Client.deleteCoupon"),
    fetchCoupon: unimplemented("Stripe.Client.fetchCoupon"),
    fetchCustomer: unimplemented("Stripe.Client.fetchCustomer"),
    fetchCustomerPaymentMethods: unimplemented("Stripe.Client.fetchCustomerPaymentMethods"),
    fetchInvoice: unimplemented("Stripe.Client.fetchInvoice"),
    fetchInvoices: unimplemented("Stripe.Client.fetchInvoices"),
    fetchPaymentIntent: unimplemented("Stripe.Client.fetchPaymentIntent"),
    fetchPaymentMethod: unimplemented("Stripe.Client.fetchPaymentMethod"),
    fetchPlans: unimplemented("Stripe.Client.fetchPlans"),
    fetchPlan: unimplemented("Stripe.Client.fetchPlan"),
    fetchSubscription: unimplemented("Stripe.Client.fetchSubscription"),
    fetchUpcomingInvoice: unimplemented("Stripe.Client.fetchUpcomingInvoice"),
    invoiceCustomer: unimplemented("Stripe.Client.invoiceCustomer"),
    updateCustomer: unimplemented("Stripe.Client.updateCustomer"),
    updateCustomerBalance: unimplemented("Stripe.Client.updateCustomerBalance"),
    updateCustomerExtraInvoiceInfo: unimplemented("Stripe.Client.updateCustomerExtraInvoiceInfo"),
    updateSubscription: unimplemented("Stripe.Client.updateSubscription"),
    js: ""
  )
}
