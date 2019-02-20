import Either
import Foundation
import Optics
import Prelude

extension Client {
  static let mock = Client(
    cancelSubscription: const(pure(.canceling)),
    createCustomer: { _, _, _, _ in pure(.mock) },
    createSubscription: { _, _, _, _ in pure(.mock) },
    fetchCoupon: const(pure(.mock)),
    fetchCustomer: const(pure(.mock)),
    fetchInvoice: const(pure(.mock(charge: .right(.mock)))),
    fetchInvoices: const(pure(.mock([.mock(charge: .right(.mock))]))),
    fetchPlans: { pure(.mock([.mock])) },
    fetchPlan: const(pure(.mock)),
    fetchSubscription: const(pure(.mock)),
    fetchUpcomingInvoice: const(pure(.upcoming)),
    invoiceCustomer: const(pure(.mock(charge: .right(.mock)))),
    updateCustomer: { _, _ in pure(.mock) },
    updateCustomerExtraInvoiceInfo: { _, _ in pure(.mock) },
    updateSubscription: { _, _, _, _ in pure(.mock) },
    js: ""
  )
}

extension Card {
  static let mock = Card(
    brand: .visa,
    customer: "cus_test",
    expMonth: 1,
    expYear: 2020,
    id: "card_test",
    last4: "4242"
  )
}

extension Charge {
  static let mock = Charge(
    amount: 17_00,
    id: "ch_test",
    source: .mock
  )
}

extension Customer {
  static let mock = Customer(
    businessVatId: nil,
    defaultSource: "card_test",
    id: "cus_test",
    metadata: [:],
    sources: .mock([.mock])
  )
}

extension StripeError {
  static let mock = StripeError(
    message: "Your card has insufficient funds."
  )
}

extension StripeErrorEnvelope {
  static let mock = StripeErrorEnvelope(
    error: .mock
  )
}

extension Event where T == Either<Invoice, Subscription> {
  static var invoice: Event<Either<Invoice, Subscription>> {
    return .init(
      data: .init(object: .left(.mock(charge: .left("ch_test")))),
      id: "evt_test",
      type: .invoicePaymentFailed
    )
  }
}

extension Invoice {
  static func mock(charge: Either<Charge.Id, Charge>?) -> Invoice {
    return Invoice(
      amountDue: 0_00,
      amountPaid: 17_00,
      charge: charge,
      closed: true,
      customer: "cus_test",
      date: .mock,
      discount: nil,
      id: "in_test",
      lines: .mock([.mock]),
      number: "0000000-0000",
      periodStart: .mock,
      periodEnd: Date.mock.addingTimeInterval(60 * 60 * 24 * 30),
      subscription: "sub_test",
      subtotal: 17_00,
      total: 17_00
    )
  }

  static let upcoming = mock(charge: .right(.mock))
    |> \.amountDue .~ 17_00
    |> \.amountPaid .~ 0
    |> \.id .~ nil
}

extension LineItem {
  static let mock = LineItem(
    amount: 17_00,
    description: nil,
    id: "ii_test",
    plan: .mock,
    quantity: 1,
    subscription: "sub_test"
  )
}

extension ListEnvelope {
  static func mock(_ xs: [A]) -> ListEnvelope<A> {
    return .init(
      data: xs,
      hasMore: false
    )
  }
}

extension Plan {
  static let mock = Plan(
    amount: 17_00,
    created: .mock,
    currency: .usd,
    id: .individualMonthly,
    interval: .month,
    metadata: [:],
    name: "Individual Monthly",
    statementDescriptor: nil
  )

  static let individualMonthly = mock

  static let individualYearly = mock
    |> \.amount .~ 170_00
    |> \.id .~ .individualYearly
    |> \.interval .~ .year
    |> \.name .~ "Individual Yearly"

  static let teamMonthly = individualMonthly
    |> \.amount .~ 16_00
    |> \.id .~ .teamMonthly
    |> \.name .~ "Team Monthly"

  static let teamYearly = individualYearly
    |> \.amount .~ 160_00
    |> \.id .~ .teamYearly
    |> \.name .~ "Team Yearly"
}

extension Subscription {
  static let mock = Subscription(
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
    start: .mock,
    status: .active
  )

  static let individualMonthly = mock
    |> \.plan .~ .individualMonthly
    |> \.quantity .~ 1

  static let individualYearly = mock
    |> \.plan .~ .individualYearly
    |> \.quantity .~ 1

  static let teamMonthly = mock
    |> \.plan .~ .teamMonthly
    |> \.quantity .~ 4

  static let teamYearly = mock
    |> \.plan .~ .teamYearly
    |> \.quantity .~ 4

  static let canceling = mock
    |> \.cancelAtPeriodEnd .~ true

  static let canceled = canceling
    |> \.canceledAt .~ Date(timeInterval: -60 * 60 * 24 * 30, since: .mock)
    |> \.currentPeriodEnd .~ Date(timeInterval: -60 * 60 * 24 * 30, since: .mock)
    |> \.currentPeriodStart .~ Date(timeInterval: -60 * 60 * 24 * 60, since: .mock)
    |> \.status .~ .canceled

  static let discounted = mock
    |> \.plan .~ .individualYearly
    |> \.quantity .~ 1
    |> \.discount .~ .mock
}

extension Discount {
  static let mock = Discount(coupon: .mock)
}

extension Coupon {
  static let mock = Coupon(
    duration: .forever,
    id: "coupon-deadbeef",
    name: "Student Discount",
    rate: .percentOff(50),
    valid: true
  )
}

extension Subscription.Item {
  static let mock = Subscription.Item(
    created: .mock,
    id: "si_test",
    plan: .mock,
    quantity: 1
  )
}

fileprivate extension Date {
  static let mock = Date(timeIntervalSince1970: 1517356800)
}
