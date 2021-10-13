import Either
import Foundation
import Tagged
import TaggedMoney

public struct Card: Codable, Equatable {
  public var brand: Brand
  public var country: Country?
  public var customer: Customer.Id
  public var expMonth: Int
  public var expYear: Int
  public var id: Id
  public var last4: String
  public var object: Object

  public init(
    brand: Brand,
    country: Country,
    customer: Customer.Id,
    expMonth: Int,
    expYear: Int,
    id: Id,
    last4: String,
    object: Object
  ) {
    self.brand = brand
    self.country = country
    self.customer = customer
    self.expMonth = expMonth
    self.expYear = expYear
    self.id = id
    self.last4 = last4
    self.object = object
  }

  public typealias Country = Tagged<(country: (), Card), String>
  public typealias Id = Tagged<Card, String>

  public enum Object: String, Codable { case card }

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
}

public struct Charge: Codable, Equatable {
  public var amount: Cents<Int>
  public var id: Id
  public var source: Either<Card, Source>

  public init(amount: Cents<Int>, id: Id, source: Either<Card, Source>) {
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

  public func discount(for cents: Cents<Int>) -> Cents<Int> {
    switch self.rate {
    case let .amountOff(amountOff):
      return cents - amountOff
    case let .percentOff(percentOff):
      return cents.map { cents -> Int in
        let discountPercent = Double(100 - percentOff) / 100
        return Int(round(Double(cents) * discountPercent))
      }
    }
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
        return "$\(Int(amountOff.map(Double.init).dollars.rawValue)) off"
      case let .percentOff(percentOff):
        return "\(percentOff)% off"
      }
    }
  }
}

public struct Source: Codable, Equatable {
  public var id: Id
  public var object: Object

  public typealias Id = Tagged<Source, String>

  public enum Object: String, Codable { case source }

  public init(id: Id, object: Object) {
    self.id = id
    self.object = object
  }
}

public enum Currency: String, Codable {
  case usd
}

public struct Customer: Codable, Equatable {
  public var balance: Cents<Int>
  public var businessVatId: Vat?
  public var defaultSource: Card.Id?
  public var id: Id
  public var metadata: [String: String]
  public var sources: ListEnvelope<Either<Card, Source>>?

  public init(
    balance: Cents<Int>,
    businessVatId: Vat?,
    defaultSource: Card.Id?,
    id: Id,
    metadata: [String: String],
    sources: ListEnvelope<Either<Card, Source>>?
  ) {
    self.balance = balance
    self.businessVatId = businessVatId
    self.defaultSource = defaultSource
    self.id = id
    self.metadata = metadata
    self.sources = sources
  }

  public typealias Id = Tagged<(Customer, id: ()), String>
  public typealias Vat = Tagged<(Customer, vat: ()), String>

  public var extraInvoiceInfo: String? {
    return self.metadata["extraInvoiceInfo"]
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

public struct StripeError: Codable, Error {
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
    case paymentIntentPaymentFailed = "payment_intent.payment_failed"
    case paymentIntentSucceeded = "payment_intent.succeeded"
  }
}

public struct Invoice: Codable, Equatable {
  public var amountDue: Cents<Int>
  public var amountPaid: Cents<Int>
  public var charge: Either<Charge.Id, Charge>?
  public var created: Date
  public var customer: Customer.Id
  public var discount: Discount?
  public var id: Id?
  public var invoicePdf: String?
  public var lines: ListEnvelope<LineItem>
  public var number: Number?
  public var periodStart: Date
  public var periodEnd: Date
  public var subscription: Subscription.Id?
  public var subtotal: Cents<Int>
  public var total: Cents<Int>

  public init(
    amountDue: Cents<Int>,
    amountPaid: Cents<Int>,
    charge: Either<Charge.Id, Charge>?,
    created: Date,
    customer: Customer.Id,
    discount: Discount?,
    id: Id?,
    invoicePdf: String?,
    lines: ListEnvelope<LineItem>,
    number: Number?,
    periodStart: Date,
    periodEnd: Date,
    subscription: Subscription.Id?,
    subtotal: Cents<Int>,
    total: Cents<Int>
  ) {
    self.amountDue = amountDue
    self.amountPaid = amountPaid
    self.charge = charge
    self.created = created
    self.customer = customer
    self.discount = discount
    self.id = id
    self.invoicePdf = invoicePdf
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
}

public struct LineItem: Codable, Equatable {
  public var amount: Cents<Int>
  public var description: String?
  public var id: Id
  public var plan: Plan?
  public var quantity: Int
  public var subscription: Subscription.Id?

  public init(
    amount: Cents<Int>,
    description: String?,
    id: Id,
    plan: Plan?,
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
}

public struct PaymentIntent: Codable, Equatable {
  public var amount: Cents<Int>
  public var clientSecret: ClientSecret
  public var currency: Currency
  public var id: Id
  public var status: Status

  public init(
    amount: Cents<Int>,
    clientSecret: ClientSecret,
    currency: Currency,
    id: Id,
    status: Status
  ) {
    self.amount = amount
    self.clientSecret = clientSecret
    self.currency = currency
    self.id = id
    self.status = status
  }

  public typealias ClientSecret = Tagged<(Self, secret: ()), String>
  public typealias Id = Tagged<Self, String>

  public enum Status: String, Codable, Equatable {
    case requiresPaymentMethod = "requires_payment_method"
    case requiresConfirmation = "requires_confirmation"
    case requiresAction = "requires_action"
    case processing
    case requiresCapture = "requires_capture"
    case canceled
    case succeeded
  }
}

public struct Plan: Codable, Equatable {
  public var created: Date
  public var currency: Currency
  public var id: Id
  public var interval: Interval
  public var metadata: [String: String]
  public var nickname: String

  public init(
    created: Date,
    currency: Currency,
    id: Id,
    interval: Interval,
    metadata: [String: String],
    nickname: String
  ) {
    self.created = created
    self.currency = currency
    self.id = id
    self.interval = interval
    self.metadata = metadata
    self.nickname = nickname
  }

  public typealias Id = Tagged<Plan, String>

  public enum Interval: String, Codable {
    case month
    case year
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
  public var startDate: Date
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
    startDate: Date,
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
    self.startDate = startDate
    self.status = status
  }

  public var isCanceling: Bool {
    return self.status == .active && self.cancelAtPeriodEnd
  }

  public var isCancellable: Bool {
    return (self.status == .active || self.status == .pastDue) && !self.cancelAtPeriodEnd
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

    public var isActive: Bool {
      switch self {
      case .active, .trialing:
        return true
      case .canceled, .pastDue, .unpaid:
        return false
      }
    }
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
    case amountOff
    case percentOff
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
    case durationInMonths
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
}
