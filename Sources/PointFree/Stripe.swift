import Either
import Foundation
import HttpPipeline
import Prelude
import Optics
import UrlFormEncoding

public struct Stripe {
  public var cancelSubscription: (Subscription.Id) -> EitherIO<Swift.Error, Subscription>
  public var createCustomer: (Database.User, Token.Id, String?) -> EitherIO<Swift.Error, Customer>
  public var createSubscription: (Customer.Id, Plan.Id, Int) -> EitherIO<Swift.Error, Subscription>
  public var fetchCustomer: (Customer.Id) -> EitherIO<Swift.Error, Customer>
  public var fetchInvoice: (Invoice.Id) -> EitherIO<Swift.Error, Invoice>
  public var fetchInvoices: (Customer.Id) -> EitherIO<Swift.Error, ListEnvelope<Invoice>>
  public var fetchPlans: EitherIO<Swift.Error, ListEnvelope<Plan>>
  public var fetchPlan: (Plan.Id) -> EitherIO<Swift.Error, Plan>
  public var fetchSubscription: (Subscription.Id) -> EitherIO<Swift.Error, Subscription>
  public var invoiceCustomer: (Customer.Id) -> EitherIO<Swift.Error, Invoice>
  public var updateCustomer: (Customer.Id, Token.Id) -> EitherIO<Swift.Error, Customer>
  public var updateCustomerExtraInvoiceInfo: (Customer.Id, String) -> EitherIO<Swift.Error, Customer>
  public var updateSubscription: (Subscription, Plan.Id, Int, Bool?) -> EitherIO<Swift.Error, Subscription>
  public var js: String

  public static let live = Stripe(
    cancelSubscription: PointFree.cancelSubscription,
    createCustomer: PointFree.createCustomer,
    createSubscription: PointFree.createSubscription,
    fetchCustomer: PointFree.fetchCustomer,
    fetchInvoice: PointFree.fetchInvoice,
    fetchInvoices: PointFree.fetchInvoices,
    fetchPlans: PointFree.fetchPlans,
    fetchPlan: PointFree.fetchPlan,
    fetchSubscription: PointFree.fetchSubscription,
    invoiceCustomer: PointFree.invoiceCustomer,
    updateCustomer: PointFree.updateCustomer(id:token:),
    updateCustomerExtraInvoiceInfo: PointFree.updateCustomer(id:extraInvoiceInfo:),
    updateSubscription: PointFree.updateSubscription,
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

  public struct Charge: Codable {
    public private(set) var amount: Cents
    public private(set) var id: Id
    public private(set) var source: Card

    public typealias Id = Tagged<Card, String>
  }

  public struct Customer: Codable {
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

  public struct ErrorEnvelope: Codable, Swift.Error {
    let error: Error
  }

  public struct Error: Codable {
    let message: String
  }

  public struct Event<T: Codable>: Codable {
    public private(set) var data: Data
    public private(set) var id: Id
    public private(set) var type: `Type`

    public typealias Id = Tagged<Event, String>

    public struct Data: Codable {
      public private(set) var object: T
    }

    public enum `Type`: String, Codable {
      case customerSubscriptionDeleted = "customer.subscription.deleted"
      case invoicePaymentFailed = "invoice.payment_failed"
      case invoicePaymentSucceeded = "invoice.payment_succeeded"
    }
  }

  public struct Invoice: Codable {
    public private(set) var amountDue: Cents
    public private(set) var amountPaid: Cents
    public private(set) var charge: Either<Charge.Id, Charge>?
    public private(set) var closed: Bool
    public private(set) var customer: Customer.Id
    public private(set) var date: Date
    public private(set) var id: Id
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

  public struct LineItem: Codable {
    public private(set) var amount: Cents
    public private(set) var description: String?
    public private(set) var id: Id
    public private(set) var plan: Plan
    public private(set) var quantity: Int
    public private(set) var subscription: Subscription.Id?

    public typealias Id = Tagged<LineItem, String>
  }

  public struct ListEnvelope<A: Codable>: Codable {
    private(set) var data: [A]
    private(set) var hasMore: Bool

    private enum CodingKeys: String, CodingKey {
      case data
      case hasMore = "has_more"
    }
  }

  public struct Plan: Codable {
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

  public struct Subscription: Codable {
    public private(set) var canceledAt: Date?
    public private(set) var cancelAtPeriodEnd: Bool
    public private(set) var created: Date
    public private(set) var currentPeriodStart: Date
    public private(set) var currentPeriodEnd: Date
    public private(set) var customer: Either<Customer.Id, Customer>
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

    public struct Item: Codable {
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

extension Stripe.ListEnvelope: Equatable where A: Equatable {
  public static func == (lhs: Stripe.ListEnvelope<A>, rhs: Stripe.ListEnvelope<A>) -> Bool {
    return lhs.data == rhs.data && lhs.hasMore == rhs.hasMore
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

private func cancelSubscription(id: Stripe.Subscription.Id) -> EitherIO<Error, Stripe.Subscription> {
  return stripeDataTask("subscriptions/" + id.rawValue + "?expand[]=customer", .delete(["at_period_end": "true"]))
}

private func createCustomer(user: Database.User, token: Stripe.Token.Id, vatNumber: String?)
  -> EitherIO<Error, Stripe.Customer> {

    return stripeDataTask("customers", .post(filteredValues <| [
      "business_vat_id": vatNumber,
      "description": user.id.rawValue.uuidString,
      "email": user.email.rawValue,
      "source": token.rawValue,
      ]))
}

private func createSubscription(
  customer: Stripe.Customer.Id,
  plan: Stripe.Plan.Id,
  quantity: Int
  )
  -> EitherIO<Error, Stripe.Subscription> {

    return stripeDataTask("subscriptions?expand[]=customer", .post([
      "customer": customer.rawValue,
      "items[0][plan]": plan.rawValue,
      "items[0][quantity]": String(quantity),
      ]))
}

private func fetchCustomer(id: Stripe.Customer.Id) -> EitherIO<Error, Stripe.Customer> {
  return stripeDataTask("customers/" + id.rawValue)
}

private func fetchInvoice(id: Stripe.Invoice.Id) -> EitherIO<Error, Stripe.Invoice> {
  return stripeDataTask("invoices/" + id.rawValue + "?expand[]=charge")
}

private func fetchInvoices(for customer: Stripe.Customer.Id) -> EitherIO<Error, Stripe.ListEnvelope<Stripe.Invoice>> {
  return stripeDataTask("invoices?customer=" + customer.rawValue + "&expand[]=data.charge&limit=100")
}

private let fetchPlans: EitherIO<Error, Stripe.ListEnvelope<Stripe.Plan>> =
  stripeDataTask("plans")

private func fetchPlan(id: Stripe.Plan.Id) -> EitherIO<Error, Stripe.Plan> {
  return stripeDataTask("plans/" + id.rawValue)
}

private func fetchSubscription(id: Stripe.Subscription.Id) -> EitherIO<Error, Stripe.Subscription> {
  return stripeDataTask("subscriptions/" + id.rawValue + "?expand[]=customer")
}

private func invoiceCustomer(_ customer: Stripe.Customer.Id)
  -> EitherIO<Error, Stripe.Invoice> {

    return stripeDataTask("invoices", .post([
      "customer": customer.rawValue,
      ]))
}

private func updateCustomer(id: Stripe.Customer.Id, token: Stripe.Token.Id)
  -> EitherIO<Error, Stripe.Customer> {

    return stripeDataTask("customers/" + id.rawValue, .post([
      "source": token.rawValue,
      ]))
}

private func updateCustomer(id: Stripe.Customer.Id, extraInvoiceInfo: String) -> EitherIO<Swift.Error, Stripe.Customer> {

  return stripeDataTask("customers/" + id.rawValue, .post([
    "metadata": ["extraInvoiceInfo": extraInvoiceInfo],
    ]))
}

private func updateSubscription(
  _ currentSubscription: Stripe.Subscription,
  _ plan: Stripe.Plan.Id,
  _ quantity: Int,
  _ prorate: Bool?
  )
  -> EitherIO<Error, Stripe.Subscription> {

    guard let item = currentSubscription.items.data.first else { return throwE(unit) }

    return stripeDataTask("subscriptions/" + currentSubscription.id.rawValue + "?expand[]=customer", .post(filteredValues <| [
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

private enum Method {
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
      <> setHeader("Idempotency-Key", UUID().uuidString)
      <> attachFormData(params)
  case let .delete(params):
    return (\.httpMethod .~ "DELETE")
      <> attachFormData(params)
  }
}

private func stripeUrlRequest(_ path: String, _ method: Method = .get) -> IO<URLRequest> {
  return IO {
    URLRequest(url: URL(string: "https://api.stripe.com/v1/" + path)!)
      |> attachMethod(method)
      <> attachBasicAuth(username: Current.envVars.stripe.secretKey)
  }
}

private func stripeDataTask<A>(_ path: String, _ method: Method = .get)
  -> EitherIO<Error, A>
  where A: Decodable {

    let task: EitherIO<Error, A> = lift(stripeUrlRequest(path, method))
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

    switch method {
    case .delete, .get:
      return task
    case .post:
      return task.retry(maxRetries: 3)
    }
}

// FIXME???
func tap<A>(_ f: @autoclosure @escaping () -> (@autoclosure () -> (A)) -> Void) -> (A) -> A {
  return {
    f()($0)
    return $0
  }
}
