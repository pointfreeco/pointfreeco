import PointFreePrelude
import XCTestDynamicOverlay

extension Client {
  public static let failing = Self(
    attachPaymentMethod: { _, _ in .failing("Stripe.Client.attachPaymentMethod") },
    cancelSubscription: { _, _ in .failing("Stripe.Client.cancelSubscription") },
    confirmPaymentIntent: { _ in .failing("Stripe.Client.confirmPaymentIntent") },
    createCoupon: { _, _, _, _ in .failing("Stripe.Client.createCoupon") },
    createCustomer: { _, _, _, _, _ in .failing("Stripe.Client.createCustomer") },
    createPaymentIntent: { _ in .failing("Stripe.Client.createPaymentIntent") },
    createSubscription: { _, _, _, _ in .failing("Stripe.Client.createSubscription") },
    deleteCoupon: { _ in .failing("Stripe.Client.deleteCoupon") },
    fetchCoupon: { _ in .failing("Stripe.Client.fetchCoupon") },
    fetchCustomer: { _ in .failing("Stripe.Client.fetchCustomer") },
    fetchCustomerPaymentMethods: { _ in .failing("Stripe.Client.fetchCustomerPaymentMethods") },
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
