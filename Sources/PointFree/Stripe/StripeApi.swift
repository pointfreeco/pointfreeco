import Either
import Foundation
import Prelude
import Optics

let fetchPlans: EitherIO<Prelude.Unit, StripeSubscriptionsEnvelope> =
  stripeDataTask("https://api.stripe.com/v1/plans")

func fetchPlan(id: StripeSubscriptionPlan.Id) -> EitherIO<Prelude.Unit, StripeSubscriptionPlan> {
  return stripeDataTask("https://api.stripe.com/v1/plans/\(id)")
}

// MARK: - Model

public struct Cents: SingleValueCodable {
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

public struct StripeSubscription: Codable {
  let id: Id
  let canceledAt: Date?
  let created: Date
  let currentPeriodStart: Date? // TODO: Audit nullability
  let currentPeriodEnd: Date? // TODO: Audit nullability
  let planId: StripeSubscriptionPlan.Id

  private enum CodingKeys: String, CodingKey {
    case id
    case canceledAt = "canceled_at"
    case created
    case currentPeriodEnd = "current_period_end"
    case currentPeriodStart = "current_period_start"
    case planId = "plan_id"
  }

  public struct Id: SingleValueCodable {
    public let rawValue: String
    public init(rawValue: String) {
      self.rawValue = rawValue
    }
  }
}

public struct StripeSubscriptionPlan: Codable {
  let amount: Cents
  let currency: Currency
  let id: String
  let interval: Interval
  let metadata: [String: String]
  let name: String
  let statementDescriptor: String?

  private enum CodingKeys: String, CodingKey {
    case amount
    case currency
    case id
    case interval
    case metadata
    case name
    case statementDescriptor = "statement_descriptor"
  }

  public struct Id: SingleValueCodable {
    public let rawValue: String
    public init(rawValue: String) {
      self.rawValue = rawValue
    }
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

private func stripeDataTask<A>(_ urlString: String) -> EitherIO<Prelude.Unit, A> where A: Decodable {
  return jsonDataTask(with: auth <| URLRequest(url: URL(string: urlString)!))
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
