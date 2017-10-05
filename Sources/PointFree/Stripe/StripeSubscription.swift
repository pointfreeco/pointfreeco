import Either
import Foundation
import Optics
import Prelude

public let subscriptionPlans: [StripeSubscriptionPlan] = [
  StripeSubscriptionPlan(
    amount: .cents(1_00),
    currency: .usd,
    id: "test",
    interval: .month,
    metadata: [:],
    name: "Test",
    statementDescriptor: nil
  ),
  StripeSubscriptionPlan(
    amount: .cents(9_00),
    currency: .usd,
    id: "monthly",
    interval: .month,
    metadata: [:],
    name: "Monthly",
    statementDescriptor: nil
  ),
  StripeSubscriptionPlan(
    amount: .cents(90_00),
    currency: .usd,
    id: "year",
    interval: .year,
    metadata: [:],
    name: "Yearly",
    statementDescriptor: nil
  ),
]

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
}

private let session = URLSession(configuration: .default)

public func bootstrapStripeSubscriptionPlans() {

  subscriptionPlans.forEach { plan in

    let tmp = fetch(plan: plan) <|> create(plan: plan)

    switch tmp.run.perform() {
    case let .left(error):
      print("error: \(error)")
    case let .right(value):
      print(value)
    }
  }
}

enum SubscriptionPlanError {
  case planNotFound
  case planExists
  case unknown
}

private func fetch(plan: StripeSubscriptionPlan) -> EitherIO<Prelude.Unit, StripeSubscriptionPlan> {

  return EitherIO<Prelude.Unit, StripeSubscriptionPlan>(run: .init { callback in
    let request = URLRequest(url: URL.init(string: "https://api.stripe.com/v1/plans/\(plan.id)")!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("\(EnvVars.Stripe.secretKey):".utf8).base64EncodedString()
    ]

    session.dataTask(with: request) { data, response, error in
      guard
        let data = data,
        let masterPlan = try? JSONDecoder().decode(StripeSubscriptionPlan.self, from: data)
        else {
          callback(.left(unit))
          return
      }

      callback(.right(masterPlan))
      }
      .resume()
    })
}

private func create(plan: StripeSubscriptionPlan) -> EitherIO<Prelude.Unit, StripeSubscriptionPlan> {

  return EitherIO<Prelude.Unit, StripeSubscriptionPlan>(run: .init { callback in
    let request = URLRequest(url: URL.init(string: "https://api.stripe.com/v1/plans")!)
      |> \.httpMethod .~ "POST"
      |> \.httpBody .~ Data(urlFormEncode(value: plan).utf8)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("\(EnvVars.Stripe.secretKey):".utf8).base64EncodedString()
    ]

    session.dataTask(with: request) { data, response, error in
      guard
        let data = data,
        let masterPlan = try? JSONDecoder().decode(StripeSubscriptionPlan.self, from: data)
        else {
          callback(.left(unit))
          return
      }

      callback(.right(masterPlan))
      }
      .resume()
    })
}

private func update(plan: StripeSubscriptionPlan) -> EitherIO<Prelude.Unit, StripeSubscriptionPlan> {

  return EitherIO<Prelude.Unit, StripeSubscriptionPlan>(run: .init { callback in
    let request = URLRequest(url: URL.init(string: "https://api.stripe.com/v1/plans/\(plan.id)")!)
      |> \.httpMethod .~ "POST"
      |> \.httpBody .~ Data(urlFormEncode(value: plan).utf8)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("\(EnvVars.Stripe.secretKey):".utf8).base64EncodedString()
    ]

    session.dataTask(with: request) { data, response, error in
      guard
        let data = data,
        let masterPlan = try? JSONDecoder().decode(StripeSubscriptionPlan.self, from: data)
        else {
          callback(.left(unit))
          return
      }

      callback(.right(masterPlan))
      }
      .resume()
    })
}

//https://api.stripe.com/v1/plans/test \
//-H 'authorization: Basic c2tfdGVzdF85M0swQWltTklYcUs4YVVaREtXY2NlWUY6' \

