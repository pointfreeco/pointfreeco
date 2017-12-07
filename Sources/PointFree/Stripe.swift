import Either
import Foundation
import HttpPipeline
import Prelude
import Optics
import UrlFormEncoding

public struct Stripe {
  public var cancelSubscription: (Subscription.Id) -> EitherIO<Prelude.Unit, Subscription>
  public var createCustomer: (Database.User, Token.Id) -> EitherIO<Prelude.Unit, Customer>
  public var createSubscription: (Customer.Id, Plan.Id) -> EitherIO<Prelude.Unit, Subscription>
  public var fetchCustomer: (Customer.Id) -> EitherIO<Prelude.Unit, Customer>
  public var fetchPlans: EitherIO<Prelude.Unit, PlansEnvelope>
  public var fetchPlan: (Plan.Id) -> EitherIO<Prelude.Unit, Plan>
  public var fetchSubscription: (Subscription.Id) -> EitherIO<Prelude.Unit, Subscription>

  public static let live = Stripe(
    cancelSubscription: PointFree.cancelSubscription,
    createCustomer: PointFree.createCustomer,
    createSubscription: PointFree.createSubscription,
    fetchCustomer: PointFree.fetchCustomer,
    fetchPlans: PointFree.fetchPlans,
    fetchPlan: PointFree.fetchPlan,
    fetchSubscription: PointFree.fetchSubscription
  )

  public typealias Cents = Tagged<Stripe, Int>

  public struct Customer: Codable {
    public let id: Id

    public typealias Id = Tagged<Customer, String>
  }

  public struct Subscription: Codable {
    public let canceledAt: Date?
    public let cancelAtPeriodEnd: Bool
    public let created: Date
    public let currentPeriodStart: Date? // TODO: Audit nullability
    public let currentPeriodEnd: Date? // TODO: Audit nullability
    public let customer: Customer.Id
    public let endedAt: Date?
    public let id: Id
    public let plan: Plan
    public let quantity: Int
    public let start: Date
    public let status: Status

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

    public typealias Id = Tagged<Subscription, String>

    public enum Status: String, Codable {
      case trialing
      case active
      case pastDue = "past_due"
      case canceled
      case unpaid
    }
  }

  public struct Plan: Codable {
    public let amount: Cents
    public let created: Date
    public let currency: Currency
    public let id: Id
    public let interval: Interval
    public let metadata: [String: String]
    public let name: String
    public let statementDescriptor: String?

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
    public let data: [Plan]
    public let hasMore: Bool

    private enum CodingKeys: String, CodingKey {
      case data
      case hasMore = "has_more"
    }
  }

  public struct Token: Codable {
    public let id: Id

    public typealias Id = Tagged<Token, String>
  }
}

//private let subscriptionPlans = fetchPlans
//  .map(^\.data >>> filter(StripeSubscriptionPlan.Id.all.contains <<< ^\.id))

private func cancelSubscription(id: Stripe.Subscription.Id) -> EitherIO<Prelude.Unit, Stripe.Subscription> {
  return stripeDataTask("https://api.stripe.com/v1/subscriptions/\(id.rawValue)", .delete)
}

private func createCustomer(user: Database.User, token: Stripe.Token.Id)
  -> EitherIO<Prelude.Unit, Stripe.Customer> {

    return stripeDataTask("https://api.stripe.com/v1/customers", .post([
      "description": user.id.unwrap.uuidString,
      "email": user.email.unwrap,
      "source": token.unwrap,
      ]))
}

private func createSubscription(customer: Stripe.Customer.Id, plan: Stripe.Plan.Id)
  -> EitherIO<Prelude.Unit, Stripe.Subscription> {

    return stripeDataTask("https://api.stripe.com/v1/subscriptions", .post([
      "customer": customer.rawValue,
      "items[0][plan]": plan.rawValue,
      ]))
}

private func fetchCustomer(id: Stripe.Customer.Id) -> EitherIO<Prelude.Unit, Stripe.Customer> {
  return stripeDataTask("https://api.stripe.com/v1/customers/\(id.unwrap)")
}

private let fetchPlans: EitherIO<Prelude.Unit, Stripe.PlansEnvelope> =
  stripeDataTask("https://api.stripe.com/v1/plans")

private func fetchPlan(id: Stripe.Plan.Id) -> EitherIO<Prelude.Unit, Stripe.Plan> {
  return stripeDataTask("https://api.stripe.com/v1/plans/\(id.rawValue)")
}

private func fetchSubscription(id: Stripe.Subscription.Id) -> EitherIO<Prelude.Unit, Stripe.Subscription> {
  return stripeDataTask("https://api.stripe.com/v1/subscriptions/\(id.unwrap)")
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

// FIXME???
func tap<A>(_ f: @autoclosure @escaping () -> (@autoclosure () -> (A)) -> Void) -> (A) -> A {
  return {
    f()($0)
    return $0
  }
}
