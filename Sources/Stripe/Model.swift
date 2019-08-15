import Either
import Foundation
import Optics
import Prelude
import PointFreePrelude
import Tagged
import TaggedMoney
import UrlFormEncoding

public struct Card: Codable, Equatable {
  public var brand: Brand
  public var customer: Customer.Id
  public var expMonth: Int
  public var expYear: Int
  public var id: Id
  public var last4: String

  public init(
    brand: Brand,
    customer: Customer.Id,
    expMonth: Int,
    expYear: Int,
    id: Id,
    last4: String
    ) {
    self.brand = brand
    self.customer = customer
    self.expMonth = expMonth
    self.expYear = expYear
    self.id = id
    self.last4 = last4
  }

  public typealias Id = Tagged<Card, String>

  public enum Brand: String, Codable, Equatable {
    case visa = "Visa"
    case americanExpress = "American Express"
    case masterCard = "MasterCard"
    case discover = "Discover"
    case jcb = "JCB"
    case dinersClub = "Diners Club"
    case unknown = "Unknown"
  }

  public enum Funding: String, Codable {
    case credit
    case debit
    case prepaid
    case unknown
  }

  private enum CodingKeys: String, CodingKey {
    case brand
    case customer
    case expMonth = "exp_month"
    case expYear = "exp_year"
    case id
    case last4
  }
}

public struct Charge: Codable, Equatable {
  public var amount: Cents<Int>
  public var id: Id
  public var source: Card

  public init(amount: Cents<Int>, id: Id, source: Card) {
    self.amount = amount
    self.id = id
    self.source = source
  }

  public typealias Id = Tagged<Charge, String>
}

public struct Coupon: Equatable {
  public var duration: Duration
  public var id: Id
  public var name: String?
  public var rate: Rate
  public var valid: Bool

  public init(duration: Duration, id: Id, name: String?, rate: Rate, valid: Bool) {
    self.duration = duration
    self.id = id
    self.name = name
    self.rate = rate
    self.valid = valid
  }

  public var formattedDescription: String {
    switch duration {
    case .forever:
      return "\(self.rate.formattedDescription) every billing period"
    case .once:
      return "\(self.rate.formattedDescription) the first billing period"
    case let .repeating(months: months):
      return "\(self.rate.formattedDescription) every billing period for the first \(months) months"
    }
  }

  public typealias Id = Tagged<Coupon, String>

  public enum Duration: Equatable {
    case forever
    case once
    case repeating(months: Int)
  }

  public enum Rate: Equatable {
    case amountOff(Cents<Int>)
    case percentOff(Int)

    public var formattedDescription: String {
      switch self {
      case let .amountOff(amountOff):
        return "$\(amountOff) off"
      case let .percentOff(percentOff):
        return "\(percentOff)% off"
      }
    }
  }
}

public struct Customer: Codable, Equatable {
  public var businessVatId: Vat?
  public var defaultSource: Card.Id?
  public var id: Id
  public var metadata: [String: String]
  public var sources: ListEnvelope<Card>

  public init(
    businessVatId: Vat?,
    defaultSource: Card.Id?,
    id: Id,
    metadata: [String: String],
    sources: ListEnvelope<Card>
    ) {
    self.businessVatId = businessVatId
    self.defaultSource = defaultSource
    self.id = id
    self.metadata = metadata
    self.sources = sources
  }

  public typealias Id = Tagged<(Customer, id: ()), String>
  public typealias Vat = Tagged<(Customer, vat: ()), String>

  private enum CodingKeys: String, CodingKey {
    case businessVatId = "business_vat_id"
    case defaultSource = "default_source"
    case id
    case metadata
    case sources
  }

  public var extraInvoiceInfo: String? {
    return self.metadata[#function]
  }
}

public struct Discount: Codable, Equatable {
  public var coupon: Coupon

  public init(coupon: Coupon) {
    self.coupon = coupon
  }
}

public struct StripeErrorEnvelope: Codable, Error {
  public var error: StripeError

  public init(error: StripeError) {
    self.error = error
  }
}

public struct StripeError: Codable {
  public var message: String

  public init(message: String) {
    self.message = message
  }
}

public struct Event<T: Codable & Equatable>: Equatable, Codable {
  public var data: Data
  public var id: Id
  public var type: `Type`

  public init(data: Data, id: Id, type: `Type`) {
    self.data = data
    self.id = id
    self.type = type
  }

  public typealias Id = Tagged<Event, String>

  public struct Data: Codable, Equatable {
    public var object: T

    public init(object: T) {
      self.object = object
    }
  }

  public enum `Type`: String, Codable, Equatable {
    case customerSubscriptionDeleted = "customer.subscription.deleted"
    case invoicePaymentFailed = "invoice.payment_failed"
    case invoicePaymentSucceeded = "invoice.payment_succeeded"
  }
}

public struct Invoice: Codable, Equatable {
  public var amountDue: Cents<Int>
  public var amountPaid: Cents<Int>
  public var charge: Either<Charge.Id, Charge>?
  public var closed: Bool
  public var customer: Customer.Id
  public var date: Date
  public var discount: Discount?
  public var id: Id?
  public var lines: ListEnvelope<LineItem>
  public var number: Number
  public var periodStart: Date
  public var periodEnd: Date
  public var subscription: Subscription.Id?
  public var subtotal: Cents<Int>
  public var total: Cents<Int>

  public init(
    amountDue: Cents<Int>,
    amountPaid: Cents<Int>,
    charge: Either<Charge.Id, Charge>?,
    closed: Bool,
    customer: Customer.Id,
    date: Date,
    discount: Discount?,
    id: Id?,
    lines: ListEnvelope<LineItem>,
    number: Number,
    periodStart: Date,
    periodEnd: Date,
    subscription: Subscription.Id?,
    subtotal: Cents<Int>,
    total: Cents<Int>
    ) {
    self.amountDue = amountDue
    self.amountPaid = amountPaid
    self.charge = charge
    self.closed = closed
    self.customer = customer
    self.date = date
    self.discount = discount
    self.id = id
    self.lines = lines
    self.number = number
    self.periodStart = periodStart
    self.periodEnd = periodEnd
    self.subscription = subscription
    self.subtotal = subtotal
    self.total = total
  }

  public typealias Id = Tagged<(Invoice, id: ()), String>
  public typealias Number = Tagged<(Invoice, number: ()), String>

  private enum CodingKeys: String, CodingKey {
    case amountDue = "amount_remaining"
    case amountPaid = "amount_paid"
    case charge
    case closed
    case customer
    case date
    case discount
    case id
    case lines
    case number
    case periodStart = "period_start"
    case periodEnd = "period_end"
    case subscription
    case subtotal
    case total
  }
}

public struct LineItem: Codable, Equatable {
  public var amount: Cents<Int>
  public var description: String?
  public var id: Id
  public var plan: Plan
  public var quantity: Int
  public var subscription: Subscription.Id?

  public init(
    amount: Cents<Int>,
    description: String?,
    id: Id,
    plan: Plan,
    quantity: Int,
    subscription: Subscription.Id?
    ) {
    self.amount = amount
    self.description = description
    self.id = id
    self.plan = plan
    self.quantity = quantity
    self.subscription = subscription
  }

  public typealias Id = Tagged<LineItem, String>
}

public struct ListEnvelope<A: Codable & Equatable>: Codable, Equatable {
  public var data: [A]
  public var hasMore: Bool

  public init(data: [A], hasMore: Bool) {
    self.data = data
    self.hasMore = hasMore
  }

  private enum CodingKeys: String, CodingKey {
    case data
    case hasMore = "has_more"
  }
}

public struct Plan: Codable, Equatable {
  public var amount: Cents<Int>
  public var created: Date
  public var currency: Currency
  public var id: Id
  public var interval: Interval
  public var metadata: [String: String]
  public var name: String
  public var statementDescriptor: String?

  public init(
    amount: Cents<Int>,
    created: Date,
    currency: Currency,
    id: Id,
    interval: Interval,
    metadata: [String: String],
    name: String,
    statementDescriptor: String?
    ) {
    self.amount = amount
    self.created = created
    self.currency = currency
    self.id = id
    self.interval = interval
    self.metadata = metadata
    self.name = name
    self.statementDescriptor = statementDescriptor
  }

  public typealias Id = Tagged<Plan, String>

  public enum Currency: String, Codable {
    case usd
  }

  public enum Interval: String, Codable {
    case month
    case year
  }

  private enum CodingKeys: String, CodingKey {
    case amount
    case created
    case currency
    case id
    case interval
    case metadata
    case name
    case statementDescriptor = "statement_descriptor"
  }
}

public struct Subscription: Codable, Equatable {
  public var canceledAt: Date?
  public var cancelAtPeriodEnd: Bool
  public var created: Date
  public var currentPeriodStart: Date
  public var currentPeriodEnd: Date
  public var customer: Either<Customer.Id, Customer>
  public var discount: Discount?
  public var endedAt: Date?
  public var id: Id
  public var items: ListEnvelope<Item>
  public var plan: Plan
  public var quantity: Int
  public var start: Date
  public var status: Status

  public init(
    canceledAt: Date?,
    cancelAtPeriodEnd: Bool,
    created: Date,
    currentPeriodStart: Date,
    currentPeriodEnd: Date,
    customer: Either<Customer.Id, Customer>,
    discount: Discount?,
    endedAt: Date?,
    id: Id,
    items: ListEnvelope<Item>,
    plan: Plan,
    quantity: Int,
    start: Date,
    status: Status
    ) {
    self.canceledAt = canceledAt
    self.cancelAtPeriodEnd = cancelAtPeriodEnd
    self.created = created
    self.currentPeriodStart = currentPeriodStart
    self.currentPeriodEnd = currentPeriodEnd
    self.customer = customer
    self.discount = discount
    self.endedAt = endedAt
    self.id = id
    self.items = items
    self.plan = plan
    self.quantity = quantity
    self.start = start
    self.status = status
  }

  public var isCanceling: Bool {
    return self.status == .active && self.cancelAtPeriodEnd
  }

  public var isRenewing: Bool {
    return self.status != .canceled && !self.cancelAtPeriodEnd
  }

  public typealias Id = Tagged<Subscription, String>

  public struct Item: Codable, Equatable {
    public var created: Date
    public var id: Id
    public var plan: Plan
    public var quantity: Int

    public init(
      created: Date,
      id: Id,
      plan: Plan,
      quantity: Int
      ) {
      self.created = created
      self.id = id
      self.plan = plan
      self.quantity = quantity
    }

    public typealias Id = Tagged<Item, String>
  }

  public enum Status: String, Codable {
    case active
    case canceled
    case pastDue = "past_due"
    case trialing
    case unpaid
  }

  private enum CodingKeys: String, CodingKey {
    case canceledAt = "canceled_at"
    case cancelAtPeriodEnd = "cancel_at_period_end"
    case customer
    case created
    case currentPeriodEnd = "current_period_end"
    case currentPeriodStart = "current_period_start"
    case discount
    case endedAt = "ended_at"
    case id
    case items
    case plan
    case quantity
    case start
    case status
  }
}

public struct Token: Codable {
  public var id: Id

  public init(id: Id) {
    self.id = id
  }

  public typealias Id = Tagged<Token, String>
}

extension Coupon.Rate: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let amountOff = try? container.decode(Cents<Int>.self, forKey: .amountOff) {
      self = .amountOff(amountOff)
    } else {
      self = try .percentOff(container.decode(Int.self, forKey: .percentOff))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .amountOff(cents):
      try container.encode(cents, forKey: .amountOff)
    case let .percentOff(percent):
      try container.encode(percent, forKey: .percentOff)
    }
  }

  public var amountOff: Cents<Int>? {
    guard case let .amountOff(cents) = self else { return nil }
    return cents
  }

  public var percentOff: Int? {
    guard case let .percentOff(percent) = self else { return nil }
    return percent
  }

  private enum CodingKeys: String, CodingKey {
    case amountOff = "amount_off"
    case percentOff = "percent_off"
  }
}

extension Coupon.Duration: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let durationKey = try container.decode(DurationKey.self, forKey: .duration)
    switch durationKey {
    case .forever:
      self = .forever
    case .once:
      self = .once
    case .repeating:
      let months = try container.decode(Int.self, forKey: .durationInMonths)
      self = .repeating(months: months)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .forever:
      try container.encode(DurationKey.forever, forKey: .duration)
    case .once:
      try container.encode(DurationKey.once, forKey: .duration)
    case let .repeating(months):
      try container.encode(DurationKey.repeating, forKey: .duration)
      try container.encode(months, forKey: .durationInMonths)
    }
  }

  private enum DurationKey: String, Codable {
    case forever
    case once
    case repeating
  }

  private enum CodingKeys: String, CodingKey {
    case duration
    case durationInMonths = "duration_in_months"
  }
}

extension Coupon: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      duration: try Coupon.Duration(from: decoder),
      id: try container.decode(Coupon.Id.self, forKey: .id),
      name: try container.decodeIfPresent(String.self, forKey: .name),
      rate: try Coupon.Rate(from: decoder),
      valid: try container.decode(Bool.self, forKey: .valid)
    )
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try self.duration.encode(to: encoder)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.name, forKey: .name)
    try self.rate.encode(to: encoder)
    try container.encode(self.valid, forKey: .valid)
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case valid
  }
}

extension Tagged where Tag == Plan, RawValue == String {
  public static var monthly: Plan.Id {
    return "monthly-2019"
  }

  public static var yearly: Plan.Id {
    return "yearly-2019"
  }

  public static var individualMonthly: Plan.Id {
    return "individual-monthly"
  }

  public static var individualYearly: Plan.Id {
    return "individual-yearly"
  }

  public static var teamMonthly: Plan.Id {
    return "team-monthly"
  }

  public static var teamYearly: Plan.Id {
    return "team-yearly"
  }
}
