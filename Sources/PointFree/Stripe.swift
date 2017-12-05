import Either
import Foundation
import HttpPipeline
import Prelude
import Optics
import UrlFormEncoding

public struct Stripe {
  var cancelSubscription: (String) -> EitherIO<Prelude.Unit, Stripe.Subscription>
  var createCustomer: (String) -> EitherIO<Prelude.Unit, Customer>
  var createSubscription: (String, Plan.Id) -> EitherIO<Prelude.Unit, Subscription>
  var fetchCustomer: (String) -> EitherIO<Prelude.Unit, Customer>
  var fetchPlans: EitherIO<Prelude.Unit, PlansEnvelope>
  var fetchPlan: (Plan.Id) -> EitherIO<Prelude.Unit, Plan>
  var fetchSubscription: (String) -> EitherIO<Prelude.Unit, Subscription>

  public static let live = Stripe(
    cancelSubscription: PointFree.cancelSubscription,
    createCustomer: PointFree.createCustomer,
    createSubscription: PointFree.createSubscription,
    fetchCustomer: PointFree.fetchCustomer,
    fetchPlans: PointFree.fetchPlans,
    fetchPlan: PointFree.fetchPlan,
    fetchSubscription: PointFree.fetchSubscription
  )

  public struct Cents: SingleValueCodable {
    public let rawValue: Int
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
  }

  public struct Customer: Codable {
    public let id: String
  }

  public struct Subscription: Codable {
    let canceledAt: Date?
    let cancelAtPeriodEnd: Bool
    let created: Date
    let currentPeriodStart: Date? // TODO: Audit nullability
    let currentPeriodEnd: Date? // TODO: Audit nullability
    let customer: String
    let endedAt: Date?
    let id: String
    let plan: Plan
    let quantity: Int
    let start: Date
    let status: Status

    private enum CodingKeys: String, CodingKey {
      case canceledAt = "canceled_at"
      case cancelAtPeriodEnd = "cancel_at_period_end"
      case customer
      case created
      case currentPeriodEnd = "current_period_end"
      case currentPeriodStart = "current_period_start"
      case endedAt = "ended_at"
      case id
      case plan
      case quantity
      case start
      case status
    }

    public enum Status: String, Codable {
      case trialing
      case active
      case pastDue = "past_due"
      case canceled
      case unpaid
    }
  }

  public struct Plan: Codable {
    let amount: Cents
    let created: Date
    let currency: Currency
    let id: Id
    let interval: Interval
    let metadata: [String: String]
    let name: String
    let statementDescriptor: String?

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

    public enum Interval: String, Codable {
      case month
      case year
    }

    public enum Currency: String, Codable {
      case usd
    }

    public enum Id: String, Codable, RawRepresentable {
      case yearly
      case monthly
      case yearlyTeam = "yearly-team"
      case monthlyTeam = "monthly-team"

      static let all: [Id] = [.yearly, .monthly, .yearlyTeam, .monthlyTeam]
    }
  }

  public struct PlansEnvelope: Codable {
    let data: [Plan]
    let hasMore: Bool

    private enum CodingKeys: String, CodingKey {
      case data
      case hasMore = "has_more"
    }
  }

  public struct Token: Codable {
    let id: String
  }
}

//private let subscriptionPlans = fetchPlans
//  .map(^\.data >>> filter(StripeSubscriptionPlan.Id.all.contains <<< ^\.id))

private func cancelSubscription(id: String) -> EitherIO<Prelude.Unit, Stripe.Subscription> {
  return stripeDataTask("https://api.stripe.com/v1/subscriptions/\(id)", .delete)
}

private func createCustomer(token: String) -> EitherIO<Prelude.Unit, Stripe.Customer> {
  return stripeDataTask("https://api.stripe.com/v1/customers", .post(["source": token]))
}

private func createSubscription(customer: String, plan: Stripe.Plan.Id)
  -> EitherIO<Prelude.Unit, Stripe.Subscription> {

    return stripeDataTask("https://api.stripe.com/v1/subscriptions", .post([
      "customer": customer,
      "items[0][plan]": plan.rawValue
      ]))
}

private func fetchCustomer(id: String) -> EitherIO<Prelude.Unit, Stripe.Customer> {
  return stripeDataTask("https://api.stripe.com/v1/customers/\(id)")
}

private let fetchPlans: EitherIO<Prelude.Unit, Stripe.PlansEnvelope> =
  stripeDataTask("https://api.stripe.com/v1/plans")

private func fetchPlan(id: Stripe.Plan.Id) -> EitherIO<Prelude.Unit, Stripe.Plan> {
  return stripeDataTask("https://api.stripe.com/v1/plans/\(id.rawValue)")
}

private func fetchSubscription(id: String) -> EitherIO<Prelude.Unit, Stripe.Subscription> {
  return stripeDataTask("https://api.stripe.com/v1/subscriptions/\(id)")
}

private let stripeJsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  return decoder
}()

private enum Method {
  case get
  case post([String: String])
  case delete
}

private func stripeDataTask<A>(_ urlString: String, _ method: Method = .get)
  -> EitherIO<Prelude.Unit, A>
  where A: Decodable {

    var request = URLRequest(url: URL(string: urlString)!)

    switch method {
    case .get:
      request.httpMethod = "GET"
    case let .post(params):
      request.httpMethod = "POST"
      request.httpBody = Data(urlFormEncode(value: params).utf8)
    case .delete:
      request.httpMethod = "DELETE"
    }

    return pure(request)
      .flatMap { jsonDataTask(with: auth <| $0) }
      .map(tap(AppEnvironment.current.logger.debug))
      .withExcept(tap(AppEnvironment.current.logger.error) >>> const(unit))
}

private func auth(_ request: URLRequest) -> URLRequest {
  return request |> \.allHTTPHeaderFields %~ attachStripeAuthorization
}

private func attachStripeAuthorization(_ headers: [String: String]?) -> [String: String] {
  let secret = Data("\(AppEnvironment.current.envVars.stripe.secretKey):".utf8).base64EncodedString()
  return (headers ?? [:])
    |> key("Authorization") .~ ("Basic " + secret) // TODO: Use key path subscript
}

public protocol SingleValueCodable: Codable, RawRepresentable {}

extension SingleValueCodable where RawValue: Codable {
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(RawValue.self))!
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.rawValue)
  }
}

// FIXME???
func tap<A>(_ f: @autoclosure @escaping () -> (@autoclosure () -> (A)) -> Void) -> (A) -> A {
  return {
    f()($0)
    return $0
  }
}
