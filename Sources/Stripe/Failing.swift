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
    fetchInvoice: { _ in .failing("Stripe.Client.fetchInvoice") },
    fetchInvoices: { _ in .failing("Stripe.Client.fetchInvoices") },
    fetchPaymentIntent: { _ in .failing("Stripe.Client.fetchPaymentIntent") },
    fetchPaymentMethod: { _ in .failing("Stripe.Client.fetchPaymentMethod") },
    fetchPlans: { .failing("Stripe.Client.fetchPlans") },
    fetchPlan: { _ in .failing("Stripe.Client.fetchPlan") },
    fetchSubscription: { _ in .failing("Stripe.Client.fetchSubscription") },
    fetchUpcomingInvoice: { _ in .failing("Stripe.Client.fetchUpcomingInvoice") },
    invoiceCustomer: { _ in .failing("Stripe.Client.invoiceCustomer") },
    updateCustomer: { _, _ in .failing("Stripe.Client.updateCustomer") },
    updateCustomerBalance: { _, _ in .failing("Stripe.Client.updateCustomerBalance") },
    updateCustomerExtraInvoiceInfo: { _, _ in
      .failing("Stripe.Client.updateCustomerExtraInvoiceInfo")
    },
    updateSubscription: { _, _, _ in .failing("Stripe.Client.updateSubscription") },
    js: ""
  )
}
