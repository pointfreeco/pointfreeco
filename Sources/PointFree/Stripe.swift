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
  public var fetchPlans: EitherIO<Swift.Error, ListEnvelope<Plan>>
  public var fetchPlan: (Plan.Id) -> EitherIO<Swift.Error, Plan>
  public var fetchSubscription: (Subscription.Id) -> EitherIO<Swift.Error, Subscription>
  public var invoiceCustomer: (Customer) -> EitherIO<Swift.Error, Invoice>
  public var updateCustomer: (Customer, Token.Id) -> EitherIO<Swift.Error, Customer>
  public var updateSubscription: (Subscription, Plan.Id, Int, Bool?) -> EitherIO<Swift.Error, Subscription>
  public var js: String

  public static let live = Stripe(
    cancelSubscription: PointFree.cancelSubscription,
    createCustomer: PointFree.createCustomer,
    createSubscription: PointFree.createSubscription,
    fetchCustomer: PointFree.fetchCustomer,
    fetchPlans: PointFree.fetchPlans,
    fetchPlan: PointFree.fetchPlan,
    fetchSubscription: PointFree.fetchSubscription,
    invoiceCustomer: PointFree.invoiceCustomer,
    updateCustomer: PointFree.updateCustomer,
    updateSubscription: PointFree.updateSubscription,
    js: "https://js.stripe.com/v3/"
  )

  public struct Card: Codable {
    public private(set) var brand: Brand
    public private(set) var customer: Customer.Id
    public private(set) var expMonth: Int
    public private(set) var expYear: Int
    public private(set) var id: Id
    public private(set) var last4: String

    public typealias Id = Tagged<Card, String>

    public enum Brand: String, Codable {
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

  public struct Customer: Codable {
    public private(set) var defaultSource: Card.Id?
    public private(set) var id: Id
    public private(set) var sources: ListEnvelope<Card>

    public typealias Id = Tagged<Customer, String>

    private enum CodingKeys: String, CodingKey {
      case defaultSource = "default_source"
      case id
      case sources
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
      case invoicePaymentFailed = "invoice.payment_failed"
    }
  }

  public struct Invoice: Codable {
    public private(set) var amountDue: Cents
    public private(set) var customer: Customer.Id
    public private(set) var id: Id
    public private(set) var subscription: Subscription.Id

    public typealias Id = Tagged<Invoice, String>

    private enum CodingKeys: String, CodingKey {
      case amountDue = "amount_due"
      case customer
      case id
      case subscription
    }
  }

  public struct ListEnvelope<A: Codable>: Codable {
    private(set) var data: [A]
    private(set) var hasMore: Bool
    private(set) var totalCount: Int

    private enum CodingKeys: String, CodingKey {
      case data
      case hasMore = "has_more"
      case totalCount = "total_count"
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

    public typealias Id = Tagged<Plan, String>

    public enum Currency: String, Codable {
      case usd
    }

    public enum Interval: String, Codable {
      case month
      case year
    }
  }

  public struct Subscription: Codable {
    public private(set) var canceledAt: Date?
    public private(set) var cancelAtPeriodEnd: Bool
    public private(set) var created: Date
    public private(set) var currentPeriodStart: Date
    public private(set) var currentPeriodEnd: Date
    public private(set) var customer: Customer
    public private(set) var endedAt: Date?
    public private(set) var id: Id
    public private(set) var items: ListEnvelope<Item>
    public private(set) var plan: Plan
    public private(set) var quantity: Int
    public private(set) var start: Date
    public private(set) var status: Status

    public var isRenewing: Bool {
      return self.status != .canceled && !self.cancelAtPeriodEnd
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
  }

  public struct Token: Codable {
    public private(set) var id: Id

    public typealias Id = Tagged<Token, String>
  }
}

extension Tagged where Tag == Stripe.Plan, A == String {
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
  return stripeDataTask("subscriptions/" + id.unwrap + "?expand[]=customer", .delete(["at_period_end": "true"]))
}

private func createCustomer(user: Database.User, token: Stripe.Token.Id, vatNumber: String?)
  -> EitherIO<Error, Stripe.Customer> {

    return stripeDataTask("customers", .post(filteredValues <| [
      "business_vat_id": vatNumber,
      "description": user.id.unwrap.uuidString,
      "email": user.email.unwrap,
      "source": token.unwrap,
      ]))
}

private func createSubscription(
  customer: Stripe.Customer.Id,
  plan: Stripe.Plan.Id,
  quantity: Int
  )
  -> EitherIO<Error, Stripe.Subscription> {

    return stripeDataTask("subscriptions?expand[]=customer", .post([
      "customer": customer.unwrap,
      "items[0][plan]": plan.unwrap,
      "items[0][quantity]": String(quantity),
      ]))
}

private func fetchCustomer(id: Stripe.Customer.Id) -> EitherIO<Error, Stripe.Customer> {
  return stripeDataTask("customers/" + id.unwrap)
}

private let fetchPlans: EitherIO<Error, Stripe.ListEnvelope<Stripe.Plan>> =
  stripeDataTask("plans")

private func fetchPlan(id: Stripe.Plan.Id) -> EitherIO<Error, Stripe.Plan> {
  return stripeDataTask("plans/" + id.unwrap)
}

private func fetchSubscription(id: Stripe.Subscription.Id) -> EitherIO<Error, Stripe.Subscription> {
  return stripeDataTask("subscriptions/" + id.unwrap + "?expand[]=customer")
}

private func invoiceCustomer(_ customer: Stripe.Customer)
  -> EitherIO<Error, Stripe.Invoice> {

    return stripeDataTask("invoices", .post([
      "customer": customer.id.unwrap,
      ]))
}

private func updateCustomer(_ customer: Stripe.Customer, _ token: Stripe.Token.Id)
  -> EitherIO<Error, Stripe.Customer> {

    return stripeDataTask("customers/" + customer.id.unwrap, .post([
      "source": token.unwrap,
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

    return stripeDataTask("subscriptions/" + currentSubscription.id.unwrap + "?expand[]=customer", .post(filteredValues <| [
      "items[0][id]": item.id.unwrap,
      "items[0][plan]": plan.unwrap,
      "items[0][quantity]": String(quantity),
      "prorate": prorate.map(String.init(describing:)),
      ]))
}

let stripeJsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  return decoder
}()

let stripeJsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .secondsSince1970
  return encoder
}()

private enum Method {
  case get
  case post([String: String])
  case delete([String: String])
}

private func stripeUrlRequest(_ path: String, _ method: Method = .get) -> IO<URLRequest> {
  return IO {
    var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/" + path)!)
    let secret = Data("\(AppEnvironment.current.envVars.stripe.secretKey):".utf8).base64EncodedString()
    var headers = ["Authorization": "Basic " + secret]

    switch method {
    case .get:
      request.httpMethod = "GET"
    case let .post(params):
      let httpBody = Data(urlFormEncode(value: params).utf8)
      request.httpMethod = "POST"
      headers["Idempotency-Key"] = UUID().uuidString
      request.httpBody = httpBody
    case let .delete(params):
      request.httpMethod = "DELETE"
      request.httpBody = Data(urlFormEncode(value: params).utf8)
    }
    request.allHTTPHeaderFields = headers

    return request
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
