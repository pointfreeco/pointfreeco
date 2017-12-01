import Either
import Foundation
import Optics
import Prelude

private let subscriptionPlanIds = [
  "yearly", "monthly", "yearly-team", "monthly-team"
]

public let subscriptionPlans = subscriptionPlanIds
  .map(fetch(planId:))
  .flatMap { $0.run.perform().right }

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

  public enum Interval: String, Codable {
    case month
    case year
  }

  public enum Currency: String, Codable {
    case usd
  }
}

public enum Cents: Codable {
  case cents(Int)

  public var value: Int {
    switch self {
    case let .cents(cents):
      return cents
    }
  }

  public init(from decoder: Decoder) throws {
    self = .cents(try decoder.singleValueContainer().decode(Int.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.value)
  }
}
