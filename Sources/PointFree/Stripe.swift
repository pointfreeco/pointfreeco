import Either
import Foundation
import HttpPipeline
import Prelude
import Optics
import UrlFormEncoding

private let subscriptionPlanIds = [
  "yearly", "monthly", "yearly-team", "monthly-team"
]

public let subscriptionPlans = fetchPlans
  .map(^\.data >>> filter(subscriptionPlanIds.contains <<< ^\.id))

// MARK: - API

let fetchPlans: EitherIO<Prelude.Unit, StripeSubscriptionsEnvelope> =
  stripeDataTask("https://api.stripe.com/v1/plans")

func fetchPlan(id: String) -> EitherIO<Prelude.Unit, StripeSubscriptionPlan> {
  return stripeDataTask("https://api.stripe.com/v1/plans/\(id)")
}

func createCustomer(token: String) -> EitherIO<Prelude.Unit, Customer> {
  return stripeDataTask("https://api.stripe.com/v1/customers", .post(["token": token]))
}

func fetchCustomer(id: String) -> EitherIO<Prelude.Unit, Customer> {
  return stripeDataTask("https://api.stripe.com/v1/customer/\(id)")
}

func createSubscription(customer: String, plan: String) -> EitherIO<Prelude.Unit, StripeSubscription> {
  return stripeDataTask("https://api.stripe.com/v1/subscriptions", .post([
    "customer": customer,
    "items[0][plan]": plan
    ]))
}

func fetchSubscription(id: String) -> EitherIO<Prelude.Unit, StripeSubscription> {
  return stripeDataTask("https://api.stripe.com/v1/subscriptions/\(id)")
}

func cancelSubscription(id: String) -> EitherIO<Prelude.Unit, StripeSubscription> {
  return stripeDataTask("https://api.stripe.com/v1/subscriptions/\(id)", .delete)
}

// MARK: - Model

public struct Cents: SingleValueCodable {
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

public struct Customer: Codable {
  public let id: String
}

public struct StripeSubscription: Codable {
  let canceledAt: Date?
  let cancelAtPeriodEnd: Bool
  let created: Date
  let currentPeriodStart: Date? // TODO: Audit nullability
  let currentPeriodEnd: Date? // TODO: Audit nullability
  let customer: String
  let endedAt: Date?
  let id: String
  let plan: StripeSubscriptionPlan
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

public struct StripeSubscriptionPlan: Codable {
  let amount: Cents
  let created: Date
  let currency: Currency
  let id: String
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
}

public struct StripeSubscriptionsEnvelope: Codable {
  let hasMore: Bool
  let data: [StripeSubscriptionPlan]

  private enum CodingKeys: String, CodingKey {
    case hasMore = "has_more"
    case data
  }
}

// MARK: -

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

    var request = auth <| URLRequest(url: URL(string: urlString)!)

    switch method {
    case .get:
      request.httpMethod = "GET"
    case let .post(params):
      request.httpMethod = "POST"
      request.httpBody = Data(urlFormEncode(value: params).utf8)
    case .delete:
      request.httpMethod = "DELETE"
    }

    return jsonDataTask(with: request)
      .withExcept(const(unit))
}

private func auth(_ request: URLRequest) -> URLRequest {
  return request |> \.allHTTPHeaderFields %~ attachStripeAuthorization
}

private func attachStripeAuthorization(_ headers: [String: String]?) -> [String: String] {
  let secret = Data("\(AppEnvironment.current.envVars.stripe.secretKey):".utf8).base64EncodedString()
  return (headers ?? [:])
    |> \.["Authorization"] .~ ("Basic " + secret)
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
