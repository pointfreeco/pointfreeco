import Either
import Foundation
import HttpPipeline
import Prelude
import Optics
import UrlFormEncoding

public struct Stripe {
  public var cancelSubscription: (Subscription.Id) -> EitherIO<Prelude.Unit, Subscription>
  public var createCustomer: (Database.User, Token.Id) -> EitherIO<Prelude.Unit, Customer>
  public var createSubscription: (Customer.Id, Plan.Id, Int) -> EitherIO<Prelude.Unit, Subscription>
  public var fetchCustomer: (Customer.Id) -> EitherIO<Prelude.Unit, Customer>
  public var fetchPlans: EitherIO<Prelude.Unit, ListEnvelope<Plan>>
  public var fetchPlan: (Plan.Id) -> EitherIO<Prelude.Unit, Plan>
  public var fetchSubscription: (Subscription.Id) -> EitherIO<Prelude.Unit, Subscription>
  public var invoiceCustomer: (Customer) -> EitherIO<Prelude.Unit, Invoice>
  public var updateCustomer: (Customer, Token.Id) -> EitherIO<Prelude.Unit, Customer>
  public var updateSubscription: (Subscription, Plan.Id, Int) -> EitherIO<Prelude.Unit, Subscription>
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
    public private(set) var defaultSource: Card.Id
    public private(set) var id: Id
    public private(set) var sources: ListEnvelope<Card>

    public typealias Id = Tagged<Customer, String>

    private enum CodingKeys: String, CodingKey {
      case defaultSource = "default_source"
      case id
      case sources
    }
  }

  public struct Invoice: Codable {
    public private(set) var id: Id

    public typealias Id = Tagged<Invoice, String>
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
    return .init(unwrap: "individual-monthly")
  }

  static var individualYearly: Stripe.Plan.Id {
    return .init(unwrap: "individual-yearly")
  }

  static var teamYearly: Stripe.Plan.Id {
    return .init(unwrap: "team-yearly")
  }
}

private func cancelSubscription(id: Stripe.Subscription.Id) -> EitherIO<Prelude.Unit, Stripe.Subscription> {
  return stripeDataTask("subscriptions/" + id.unwrap, .delete(["at_period_end": "true"]))
}

private func createCustomer(user: Database.User, token: Stripe.Token.Id)
  -> EitherIO<Prelude.Unit, Stripe.Customer> {

    return stripeDataTask("customers", .post([
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
  -> EitherIO<Prelude.Unit, Stripe.Subscription> {

    return stripeDataTask("subscriptions?expand[]=customer", .post([
      "customer": customer.unwrap,
      "items[0][plan]": plan.unwrap,
      "items[0][quantity]": String(quantity),
      ]))
}

private func fetchCustomer(id: Stripe.Customer.Id) -> EitherIO<Prelude.Unit, Stripe.Customer> {
  return stripeDataTask("customers/" + id.unwrap)
}

private let fetchPlans: EitherIO<Prelude.Unit, Stripe.ListEnvelope<Stripe.Plan>> =
  stripeDataTask("plans")

private func fetchPlan(id: Stripe.Plan.Id) -> EitherIO<Prelude.Unit, Stripe.Plan> {
  return stripeDataTask("plans/" + id.unwrap)
}

private func fetchSubscription(id: Stripe.Subscription.Id) -> EitherIO<Prelude.Unit, Stripe.Subscription> {
  return stripeDataTask("subscriptions/" + id.unwrap + "?expand[]=customer")
}

private func invoiceCustomer(_ customer: Stripe.Customer)
  -> EitherIO<Prelude.Unit, Stripe.Invoice> {

    return stripeDataTask("invoices", .post([
      "customer": customer.id.unwrap,
      ]))
}

private func updateCustomer(_ customer: Stripe.Customer, _ token: Stripe.Token.Id)
  -> EitherIO<Prelude.Unit, Stripe.Customer> {

    return stripeDataTask("customers/" + customer.id.unwrap, .post([
      "source": token.unwrap,
      ]))
}

private func updateSubscription(
  _ subscription: Stripe.Subscription,
  _ plan: Stripe.Plan.Id,
  _ quantity: Int
  )
  -> EitherIO<Prelude.Unit, Stripe.Subscription> {

    guard let item = subscription.items.data.first else { return throwE(unit) }
    return stripeDataTask("subscriptions/" + subscription.id.unwrap + "?expand[]=customer", .post([
      "items[0][id]": item.id.unwrap,
      "items[0][plan]": plan.unwrap,
      "items[0][quantity]": String(quantity),
      ]))
}

private let stripeJsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  return decoder
}()

private enum Method {
  case get
  case post([String: String])
  case delete([String: String])

  var isPost: Bool {
    if case .post = self { return true }
    return false
  }
}

private func stripeUrlRequest(_ path: String, _ method: Method = .get) -> URLRequest {
  var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/" + path)!)

  switch method {
  case .get:
    request.httpMethod = "GET"
  case let .post(params):
    request.httpMethod = "POST"
    request.httpBody = Data(urlFormEncode(value: params).utf8)
    request.allHTTPHeaderFields = ["Idempotency-Key": UUID().uuidString]
  case let .delete(params):
    request.httpMethod = "DELETE"
    request.httpBody = Data(urlFormEncode(value: params).utf8)
  }

  return request
}

private func stripeDataTask<A>(_ path: String, _ method: Method = .get)
  -> EitherIO<Prelude.Unit, A>
  where A: Decodable {

    let task: EitherIO<Prelude.Unit, A> = pure(stripeUrlRequest(path, method))
      .flatMap { jsonDataTask(with: auth <| $0, decoder: stripeJsonDecoder) }
      .map(tap(AppEnvironment.current.logger.debug))
      .withExcept(tap(AppEnvironment.current.logger.error) >>> const(unit))

    return method.isPost
      ? task.retry(maxRetries: 10)
      : task
}

private func auth(_ request: URLRequest) -> URLRequest {
  return request |> \.allHTTPHeaderFields %~ attachStripeAuthorization
}

private func attachStripeAuthorization(_ headers: [String: String]?) -> [String: String] {
  let secret = Data("\(AppEnvironment.current.envVars.stripe.secretKey):".utf8).base64EncodedString()
  return (headers ?? [:])
    |> key("Authorization") .~ ("Basic " + secret) // TODO: Use key path subscript
}

// FIXME???
func tap<A>(_ f: @autoclosure @escaping () -> (@autoclosure () -> (A)) -> Void) -> (A) -> A {
  return {
    f()($0)
    return $0
  }
}
