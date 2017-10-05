import Either
import Foundation
import Optics
import Prelude

public let subscriptionPlans: [StripeSubscriptionPlan] = [
  StripeSubscriptionPlan(
    amount: 1, currency: .usd, id: "test", interval: .month, name: "Test", statementDescriptor: nil
  ),
  StripeSubscriptionPlan(
    amount: 9, currency: .usd, id: "monthly", interval: .month, name: "Monthly", statementDescriptor: nil
  ),
  StripeSubscriptionPlan(
    amount: 90, currency: .usd, id: "year", interval: .year, name: "Yearly", statementDescriptor: nil
  ),
]

public struct StripeSubscriptionPlan: Codable {
  let amount: Int
  let currency: Currency
  let id: String
  let interval: Interval
  let name: String
  let statementDescriptor: String?

  private enum CodingKeys: String, CodingKey {
    case amount
    case currency
    case id
    case interval
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

  public var urlEncodedString: String {
    return """
    amount=\(self.amount * 100)&\
    currency=\(self.currency)&\
    id=\(self.id)&\
    interval=\(self.interval)&\
    name=\(self.name)&
    statement_descriptor=\(statementDescriptor ?? "")
    """
  }
}

private let session = URLSession(configuration: .default)

public func bootstrapStripeSubscriptionPlans() {

  subscriptionPlans.forEach { plan in

    let tmp = fetch(plan: plan).flatMap(update(plan:)) <|> update(plan: plan)

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

    session.dataTask(with: request) { data, response, errro in
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
      |> \.httpBody .~ Data(plan.urlEncodedString.utf8)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("\(EnvVars.Stripe.secretKey):".utf8).base64EncodedString()
    ]

    session.dataTask(with: request) { data, response, errro in
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
      |> \.httpMethod .~ "PUT"
      |> \.httpBody .~ Data(plan.urlEncodedString.utf8)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("\(EnvVars.Stripe.secretKey):".utf8).base64EncodedString()
    ]

    session.dataTask(with: request) { data, response, errro in
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

