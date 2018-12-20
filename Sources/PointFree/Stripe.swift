import Either
import Foundation
import HttpPipeline
import Prelude
import Optics
import UrlFormEncoding

public struct Stripe {
  public var cancelSubscription: (Subscription.Id) -> EitherIO<Swift.Error, Subscription>
  public var createCustomer: (Database.User, Token.Id, String?) -> EitherIO<Swift.Error, Customer>
  public var createSubscription: (Customer.Id, Plan.Id, Int, SubscribeData.Coupon?) -> EitherIO<Swift.Error, Subscription>
  public var fetchCoupon: (Coupon.Id) -> EitherIO<Swift.Error, Coupon>
  public var fetchCustomer: (Customer.Id) -> EitherIO<Swift.Error, Customer>
  public var fetchInvoice: (Invoice.Id) -> EitherIO<Swift.Error, Invoice>
  public var fetchInvoices: (Customer.Id) -> EitherIO<Swift.Error, ListEnvelope<Invoice>>
  public var fetchPlans: () -> EitherIO<Swift.Error, ListEnvelope<Plan>>
  public var fetchPlan: (Plan.Id) -> EitherIO<Swift.Error, Plan>
  public var fetchSubscription: (Subscription.Id) -> EitherIO<Swift.Error, Subscription>
  public var fetchUpcomingInvoice: (Customer.Id) -> EitherIO<Swift.Error, Invoice>
  public var invoiceCustomer: (Customer.Id) -> EitherIO<Swift.Error, Invoice>
  public var updateCustomer: (Customer.Id, Token.Id) -> EitherIO<Swift.Error, Customer>
  public var updateCustomerExtraInvoiceInfo: (Customer.Id, String) -> EitherIO<Swift.Error, Customer>
  public var updateSubscription: (Subscription, Plan.Id, Int, Bool?) -> EitherIO<Swift.Error, Subscription>
  public var js: String

  public static let live = Stripe(
    cancelSubscription: PointFree.cancelSubscription >>> runStripe,
    createCustomer: { PointFree.createCustomer(user: $0, token: $1, vatNumber: $2) |> runStripe },
    createSubscription: {
      PointFree.createSubscription(customer: $0, plan: $1, quantity: $2, coupon: $3) |> runStripe },
    fetchCoupon: PointFree.fetchCoupon >>> runStripe,
    fetchCustomer: PointFree.fetchCustomer >>> runStripe,
    fetchInvoice: PointFree.fetchInvoice >>> runStripe,
    fetchInvoices: PointFree.fetchInvoices >>> runStripe,
    fetchPlans: { PointFree.fetchPlans() |> runStripe },
    fetchPlan: PointFree.fetchPlan >>> runStripe,
    fetchSubscription: PointFree.fetchSubscription >>> runStripe,
    fetchUpcomingInvoice: PointFree.fetchUpcomingInvoice >>> runStripe,
    invoiceCustomer: PointFree.invoiceCustomer >>> runStripe,
    updateCustomer: { PointFree.updateCustomer(id: $0, token: $1) |> runStripe },
    updateCustomerExtraInvoiceInfo: { PointFree.updateCustomer(id: $0, extraInvoiceInfo: $1) |> runStripe },
    updateSubscription: { PointFree.updateSubscription($0, $1, $2, $3) |> runStripe },
    js: "https://js.stripe.com/v3/"
  )

  public struct Card: Codable, Equatable {
    public private(set) var brand: Brand
    public private(set) var customer: Customer.Id
    public private(set) var expMonth: Int
    public private(set) var expYear: Int
    public private(set) var id: Id
    public private(set) var last4: String

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

  public typealias Cents = Tagged<Stripe, Int>

  public struct Charge: Codable, Equatable {
    public private(set) var amount: Cents
    public private(set) var id: Id
    public private(set) var source: Card

    public typealias Id = Tagged<Card, String>
  }

  public struct Coupon: Equatable {
    public typealias Id = Tagged<Coupon, String>

    public private(set) var duration: Duration
    public private(set) var id: Id
    public private(set) var name: String?
    public private(set) var rate: Rate
    public private(set) var valid: Bool

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

    public enum Duration: Equatable {
      case forever
      case once
      case repeating(months: Int)
    }

    public enum Rate: Equatable {
      case amountOff(Cents)
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
    public private(set) var businessVatId: Vat?
    public private(set) var defaultSource: Card.Id?
    public private(set) var id: Id
    public private(set) var metadata: [String: String]
    public private(set) var sources: ListEnvelope<Card>

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
    public private(set) var coupon: Coupon
  }

  public struct ErrorEnvelope: Codable, Swift.Error {
    let error: Error
  }

  public struct Error: Codable {
    let message: String
  }

  public struct Event<T: Codable & Equatable>: Equatable, Codable {
    public private(set) var data: Data
    public private(set) var id: Id
    public private(set) var type: `Type`

    public typealias Id = Tagged<Event, String>

    public struct Data: Codable, Equatable {
      public private(set) var object: T
    }

    public enum `Type`: String, Codable, Equatable {
      case customerSubscriptionDeleted = "customer.subscription.deleted"
      case invoicePaymentFailed = "invoice.payment_failed"
      case invoicePaymentSucceeded = "invoice.payment_succeeded"
    }
  }

  public struct Invoice: Codable, Equatable {
    public private(set) var amountDue: Cents
    public private(set) var amountPaid: Cents
    public private(set) var charge: Either<Charge.Id, Charge>?
    public private(set) var closed: Bool
    public private(set) var customer: Customer.Id
    public private(set) var date: Date
    public private(set) var discount: Discount?
    public private(set) var id: Id?
    public private(set) var lines: ListEnvelope<LineItem>
    public private(set) var number: Number
    public private(set) var periodStart: Date
    public private(set) var periodEnd: Date
    public private(set) var subscription: Subscription.Id?
    public private(set) var subtotal: Cents
    public private(set) var total: Cents

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
    public private(set) var amount: Cents
    public private(set) var description: String?
    public private(set) var id: Id
    public private(set) var plan: Plan
    public private(set) var quantity: Int
    public private(set) var subscription: Subscription.Id?

    public typealias Id = Tagged<LineItem, String>
  }

  public struct ListEnvelope<A: Codable & Equatable>: Codable, Equatable {
    private(set) var data: [A]
    private(set) var hasMore: Bool

    private enum CodingKeys: String, CodingKey {
      case data
      case hasMore = "has_more"
    }
  }

  public struct Plan: Codable, Equatable {
    public private(set) var amount: Cents
    public private(set) var created: Date
    public private(set) var currency: Currency
    public private(set) var id: Id
    public private(set) var interval: Interval
    public private(set) var metadata: [String: String]
    public private(set) var name: String
    public private(set) var statementDescriptor: String?

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
    public private(set) var canceledAt: Date?
    public private(set) var cancelAtPeriodEnd: Bool
    public private(set) var created: Date
    public private(set) var currentPeriodStart: Date
    public private(set) var currentPeriodEnd: Date
    public private(set) var customer: Either<Customer.Id, Customer>
    public private(set) var discount: Discount?
    public private(set) var endedAt: Date?
    public private(set) var id: Id
    public private(set) var items: ListEnvelope<Item>
    public private(set) var plan: Plan
    public private(set) var quantity: Int
    public private(set) var start: Date
    public private(set) var status: Status

    public var isCanceling: Bool {
      return self.status == .active && self.cancelAtPeriodEnd
    }

    public var isRenewing: Bool {
      return self.status != .canceled && !self.cancelAtPeriodEnd
    }

    public typealias Id = Tagged<Subscription, String>

    public struct Item: Codable, Equatable {
      public private(set) var created: Date
      public private(set) var id: Id
      public private(set) var plan: Plan
      public private(set) var quantity: Int

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
    public private(set) var id: Id

    public typealias Id = Tagged<Token, String>
  }
}

extension Stripe.Coupon.Rate: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let amountOff = try? container.decode(Stripe.Cents.self, forKey: .amountOff) {
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

  public var amountOff: Stripe.Cents? {
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

extension Stripe.Coupon.Duration: Codable {
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

extension Stripe.Coupon: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      duration: try Stripe.Coupon.Duration(from: decoder),
      id: try container.decode(Stripe.Coupon.Id.self, forKey: .id),
      name: try container.decodeIfPresent(String.self, forKey: .name),
      rate: try Stripe.Coupon.Rate(from: decoder),
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

extension Tagged where Tag == Stripe.Plan, RawValue == String {
  static var individualMonthly: Stripe.Plan.Id {
    return "individual-monthly"
  }

  static var individualYearly: Stripe.Plan.Id {
    return "individual-yearly"
  }

  static var teamMonthly: Stripe.Plan.Id {
    return "team-monthly"
  }

  static var teamYearly: Stripe.Plan.Id {
    return "team-yearly"
  }
}

func cancelSubscription(id: Stripe.Subscription.Id) -> DecodableRequest<Stripe.Subscription> {
  return stripeRequest(
    "subscriptions/" + id.rawValue + "?expand[]=customer", .delete(["at_period_end": "true"])
  )
}

func createCustomer(user: Database.User, token: Stripe.Token.Id, vatNumber: String?)
  -> DecodableRequest<Stripe.Customer> {

    return stripeRequest("customers", .post(filteredValues <| [
      "business_vat_id": vatNumber,
      "description": user.id.rawValue.uuidString,
      "email": user.email.rawValue,
      "source": token.rawValue,
      ]))
}

func createSubscription(
  customer: Stripe.Customer.Id,
  plan: Stripe.Plan.Id,
  quantity: Int,
  coupon: SubscribeData.Coupon?
  )
  -> DecodableRequest<Stripe.Subscription> {

    var params: [String: Any] = [:]
    params["customer"] = customer.rawValue
    params["items[0][plan]"] = plan.rawValue
    params["items[0][quantity]"] = String(quantity)
    params["coupon"] = coupon?.rawValue

    return stripeRequest("subscriptions?expand[]=customer", .post(params))
}

func fetchCoupon(id: Stripe.Coupon.Id) -> DecodableRequest<Stripe.Coupon> {
  return stripeRequest("coupons/" + id.rawValue)
}

func fetchCustomer(id: Stripe.Customer.Id) -> DecodableRequest<Stripe.Customer> {
  return stripeRequest("customers/" + id.rawValue)
}

func fetchInvoice(id: Stripe.Invoice.Id) -> DecodableRequest<Stripe.Invoice> {
  return stripeRequest("invoices/" + id.rawValue + "?expand[]=charge")
}

func fetchInvoices(for customer: Stripe.Customer.Id) -> DecodableRequest<Stripe.ListEnvelope<Stripe.Invoice>> {
  return stripeRequest("invoices?customer=" + customer.rawValue + "&expand[]=data.charge&limit=100")
}

func fetchPlans() -> DecodableRequest<Stripe.ListEnvelope<Stripe.Plan>> {
  return stripeRequest("plans")
}

func fetchPlan(id: Stripe.Plan.Id) -> DecodableRequest<Stripe.Plan> {
  return stripeRequest("plans/" + id.rawValue)
}

func fetchSubscription(id: Stripe.Subscription.Id) -> DecodableRequest<Stripe.Subscription> {
  return stripeRequest("subscriptions/" + id.rawValue + "?expand[]=customer")
}

func fetchUpcomingInvoice(_ customer: Stripe.Customer.Id) -> DecodableRequest<Stripe.Invoice> {
  return stripeRequest("invoices/upcoming?customer=" + customer.rawValue + "&expand[]=charge")
}

func invoiceCustomer(_ customer: Stripe.Customer.Id)
  -> DecodableRequest<Stripe.Invoice> {

    return stripeRequest("invoices", .post([
      "customer": customer.rawValue,
      ]))
}

func updateCustomer(id: Stripe.Customer.Id, token: Stripe.Token.Id)
  -> DecodableRequest<Stripe.Customer> {

    return stripeRequest("customers/" + id.rawValue, .post([
      "source": token.rawValue,
      ]))
}

func updateCustomer(id: Stripe.Customer.Id, extraInvoiceInfo: String) -> DecodableRequest<Stripe.Customer> {

  return stripeRequest("customers/" + id.rawValue, .post([
    "metadata": ["extraInvoiceInfo": extraInvoiceInfo],
    ]))
}

func updateSubscription(
  _ currentSubscription: Stripe.Subscription,
  _ plan: Stripe.Plan.Id,
  _ quantity: Int,
  _ prorate: Bool?
  )
  -> DecodableRequest<Stripe.Subscription>? {

    guard let item = currentSubscription.items.data.first else { return nil }

    return stripeRequest("subscriptions/" + currentSubscription.id.rawValue + "?expand[]=customer", .post(filteredValues <| [
      "coupon": "",
      "items[0][id]": item.id.rawValue,
      "items[0][plan]": plan.rawValue,
      "items[0][quantity]": String(quantity),
      "prorate": prorate.map(String.init(describing:)),
      ]))
}

let stripeJsonDecoder = JSONDecoder()
  |> \.dateDecodingStrategy .~ .secondsSince1970
//  |> \.keyDecodingStrategy .~ .convertFromSnakeCase

let stripeJsonEncoder = JSONEncoder()
  |> \.dateEncodingStrategy .~ .secondsSince1970
//  |> \.keyEncodingStrategy .~ .convertToSnakeCase

enum Method {
  case get
  case post([String: Any])
  case delete([String: String])
}

private func attachMethod(_ method: Method) -> (URLRequest) -> URLRequest {
  switch method {
  case .get:
    return \.httpMethod .~ "GET"
  case let .post(params):
    return (\.httpMethod .~ "POST")
      <> setHeader("Idempotency-Key", Current.uuid().uuidString)
      <> attachFormData(params)
  case let .delete(params):
    return (\.httpMethod .~ "DELETE")
      <> attachFormData(params)
  }
}

func stripeRequest<A>(_ path: String, _ method: Method = .get) -> DecodableRequest<A> {
  return DecodableRequest(
    rawValue: URLRequest(url: URL(string: "https://api.stripe.com/v1/" + path)!)
      |> attachMethod(method)
      <> attachBasicAuth(username: Current.envVars.stripe.secretKey)
  )
}

private func runStripe<A>(_ stripeRequest: DecodableRequest<A>?) -> EitherIO<Error, A> {
  guard let stripeRequest = stripeRequest else { return throwE(unit) }

  let task: EitherIO<Error, A> = pure(stripeRequest.rawValue)
    .flatMap {
      dataTask(with: $0)
        .map(first)
        .flatMap { data in
          .wrap {
            do {
              return try stripeJsonDecoder.decode(A.self, from: data)
            } catch {
              throw (try? stripeJsonDecoder.decode(Stripe.ErrorEnvelope.self, from: data))
                ?? JSONError.error(String(decoding: data, as: UTF8.self), error) as Error
            }
          }
      }
  }

  return task
}

// FIXME???
func tap<A>(_ f: @autoclosure @escaping () -> (@autoclosure () -> (A)) -> Void) -> (A) -> A {
  return {
    f()($0)
    return $0
  }
}
