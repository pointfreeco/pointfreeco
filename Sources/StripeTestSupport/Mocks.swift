import Either
import Foundation
import PointFreePrelude
import Prelude
import Stripe

extension Client {
  public static let mock = Client(
    attachPaymentMethod: { _, _ in .mock },
    cancelSubscription: { _, _ in .canceling },
    confirmPaymentIntent: { _ in .succeeded },
    createCoupon: { _, _, _, _ in .mock },
    createCustomer: { _, _, _, _, _ in .mock },
    createPaymentIntent: { _ in .requiresConfirmation },
    createSubscription: { _, _, _, _ in .mock },
    deleteCoupon: { _ in },
    fetchCoupon: { _ in .mock },
    fetchCustomer: const(pure(.mock)),
    fetchCustomerPaymentMethods: { _ in pure(.mock([])) },
    fetchInvoice: const(pure(.mock(charge: .right(.mock)))),
    fetchInvoices: const(pure(.mock([.mock(charge: .right(.mock))]))),
    fetchPaymentIntent: const(pure(.succeeded)),
    fetchPaymentMethod: { _ in pure(.mock) },
    fetchPlans: { pure(.mock([.mock])) },
    fetchPlan: const(pure(.mock)),
    fetchSubscription: const(pure(.mock)),
    fetchUpcomingInvoice: const(pure(.upcoming)),
    invoiceCustomer: const(pure(.mock(charge: .right(.mock)))),
    updateCustomer: { _, _ in pure(.mock) },
    updateCustomerBalance: { _, cents in pure(update(.mock) { $0.balance = cents }) },
    updateCustomerExtraInvoiceInfo: { _, _ in pure(.mock) },
    updateSubscription: { _, _, _ in pure(.mock) },
    js: ""
  )
}

extension Card {
  public static let mock = Card(
    brand: .visa,
    country: "US",
    customer: "cus_test",
    expMonth: 1,
    expYear: 2020,
    id: "card_test",
    last4: "4242",
    object: Object.card
  )
}

extension PaymentIntent {
  public static let requiresConfirmation = Self(
    amount: 54_00,
    clientSecret: "pi_test_secret_test",
    currency: .usd,
    id: "pi_test",
    status: .requiresConfirmation
  )

  public static let succeeded = Self(
    amount: 54_00,
    clientSecret: "pi_test_secret_test",
    currency: .usd,
    id: "pi_test",
    status: .succeeded
  )
}

extension Source {
  public static let mock = Source(
    id: "src_DEADBEEF",
    object: .source
  )
}

extension Charge {
  public static let mock = Charge(
    amount: 17_00,
    id: "ch_test",
    paymentMethodDetails: .mock
  )
}

extension Charge.PaymentMethodDetails {
  public static let mock = Self(
    card: .init(
      brand: .visa,
      country: "US",
      expMonth: 1,
      expYear: 2020,
      funding: .credit,
      last4: "4242"
    )
  )
}

extension Customer {
  public static let mock = Customer(
    balance: 0,
    businessVatId: nil,
    defaultSource: nil,
    id: "cus_test",
    invoiceSettings: .init(defaultPaymentMethod: "pm_card_test"),
    metadata: [:]
  )
}

extension StripeError {
  public static let mock = StripeError(
    message: "Your card has insufficient funds."
  )
}

extension StripeErrorEnvelope {
  public static let mock = StripeErrorEnvelope(
    error: .mock
  )
}

extension Event where T == Either<Invoice, Subscription> {
  public static var invoice: Event<Either<Invoice, Subscription>> {
    return .init(
      data: .init(object: .left(.mock(charge: .left("ch_test")))),
      id: "evt_test",
      type: .invoicePaymentFailed
    )
  }
}

extension Invoice {
  public static func mock(charge: Expandable<Charge>?) -> Invoice {
    return Invoice(
      amountDue: 0_00,
      amountPaid: 17_00,
      charge: charge,
      created: .mock,
      customer: "cus_test",
      discount: nil,
      id: "in_test",
      invoicePdf: "https://pay.stripe.com/invoice/invst_test/pdf",
      lines: .mock([.mock]),
      number: "0000000-0000",
      periodStart: .mock,
      periodEnd: Date.mock.addingTimeInterval(60 * 60 * 24 * 30),
      subscription: "sub_test",
      subtotal: 17_00,
      total: 17_00
    )
  }

  public static let upcoming = update(mock(charge: .right(.mock))) {
    $0.amountDue = 17_00
    $0.amountPaid = 0
    $0.id = nil
  }
}

extension LineItem {
  public static let mock = LineItem(
    amount: 17_00,
    description: nil,
    id: "ii_test",
    plan: .mock,
    quantity: 1,
    subscription: "sub_test"
  )
}

extension ListEnvelope {
  public static func mock(_ xs: [A]) -> ListEnvelope<A> {
    return .init(
      data: xs,
      hasMore: false
    )
  }
}

extension PaymentMethod {
  public static let mock = Self(
    card: .mock,
    customer: .left("cus_test"),
    id: "pm_card"
  )
}

extension PaymentMethod.Card {
  public static let mock = Self(
    brand: .visa,
    country: "US",
    expMonth: 1,
    expYear: 2020,
    funding: .credit,
    last4: "4242"
  )

  public static let regional = Self(
    brand: .visa,
    country: "BO",
    expMonth: 1,
    expYear: 2020,
    funding: .credit,
    last4: "4242"
  )
}

extension Plan {
  public static let mock = Plan(
    created: .mock,
    currency: .usd,
    id: .monthly,
    interval: .month,
    metadata: [:],
    nickname: "Individual Monthly"
  )

  public static let individualMonthly = mock

  public static let individualYearly = update(mock) {
    $0.id = .yearly
    $0.interval = .year
    $0.nickname = "Individual Yearly"
  }

  public static let teamMonthly = update(individualMonthly) {
    $0.id = .monthly
    $0.nickname = "Team Monthly"
  }

  public static let teamYearly = update(individualYearly) {
    $0.id = .yearly
    $0.nickname = "Team Yearly"
  }
}

extension Subscription {
  public static let mock = Subscription(
    canceledAt: nil,
    cancelAtPeriodEnd: false,
    created: .mock,
    currentPeriodStart: .mock,
    currentPeriodEnd: Date(timeInterval: 60 * 60 * 24 * 30, since: .mock),
    customer: .right(.mock),
    discount: nil,
    endedAt: nil,
    id: "sub_test",
    items: .mock([.mock]),
    plan: .mock,
    quantity: 1,
    startDate: .mock,
    status: .active
  )

  public static let individualMonthly = update(mock) {
    $0.plan = .individualMonthly
    $0.quantity = 1
  }

  public static let individualYearly = update(mock) {
    $0.plan = .individualYearly
    $0.quantity = 1
  }

  public static let teamMonthly = update(mock) {
    $0.plan = .teamMonthly
    $0.quantity = 4
  }

  public static let teamYearly = update(mock) {
    $0.plan = .teamYearly
    $0.quantity = 4
  }

  public static let canceling = update(mock) {
    $0.cancelAtPeriodEnd = true
  }

  public static let canceled = update(canceling) {
    $0.canceledAt = .some(Date(timeInterval: -60 * 60 * 24 * 30, since: .mock))
    $0.currentPeriodEnd = Date(timeInterval: -60 * 60 * 24 * 30, since: .mock)
    $0.currentPeriodStart = Date(timeInterval: -60 * 60 * 24 * 60, since: .mock)
    $0.status = .canceled
  }

  public static let discounted = update(mock) {
    $0.plan = .individualYearly
    $0.quantity = 1
    $0.discount = .mock
  }
}

extension Discount {
  public static let mock = Discount(coupon: .mock)
}

extension Coupon {
  public static let mock = Coupon(
    duration: .forever,
    id: "coupon-deadbeef",
    name: "Student Discount",
    rate: .percentOff(50),
    valid: true
  )
}

extension Subscription.Item {
  public static let mock = Subscription.Item(
    created: .mock,
    id: "si_test",
    plan: .mock,
    quantity: 1
  )
}

extension Date {
  fileprivate static let mock = Date(timeIntervalSince1970: 1_517_356_800)
}
