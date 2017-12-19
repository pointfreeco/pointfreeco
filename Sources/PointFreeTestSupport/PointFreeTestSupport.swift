import Foundation
import Either
@testable import PointFree
import Prelude

extension Environment {
  public static let mock = Environment(
    airtableStuff: const(const(pure(unit))),
    database: .mock,
    envVars: EnvVars(),
    gitHub: .mock,
    logger: .mock,
    sendEmail: const(pure(.init(id: "deadbeef", message: "success!"))),
    stripe: .mock
  )
}

extension Logger {
  public static let mock = Logger(level: .debug, logger: { _ in })
}

extension Database {
  public static let mock = Database(
    createSubscription: { _, _ in pure(unit) },
    fetchUserByGitHub: const(pure(.mock)),
    fetchUserById: const(pure(.mock)),
    upsertUser: const(pure(.mock)),
    migrate: { pure(unit) }
  )
}

extension Database.User {
  public static let mock = Database.User(
    email: .init(unwrap: "hello@pointfree.co"),
    gitHubUserId: .init(unwrap: 1),
    gitHubAccessToken: "deadbeef",
    id: .init(unwrap: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    name: "Blob",
    subscriptionId: .init(unwrap: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
  )
}

extension GitHub {
  public static let mock = GitHub(
    fetchAuthToken: const(pure(.mock)),
    fetchUser: const(pure(.mock))
  )
}

extension GitHub.AccessToken {
  public static let mock = GitHub.AccessToken(
    accessToken: "deadbeef"
  )
}

extension GitHub.User {
  public static let mock = GitHub.User(
    email: .init(unwrap: "hello@pointfree.co"),
    id: .init(unwrap: 1),
    name: "Blob"
  )
}

extension GitHub.UserEnvelope {
  public static let mock = GitHub.UserEnvelope(
    accessToken: .mock,
    gitHubUser: .mock
  )
}

extension Stripe {
  public static let mock = Stripe(
    cancelSubscription: const(pure(.mock)),
    createCustomer: { _, _ in pure(.mock) },
    createSubscription: { _, _ in pure(.mock) },
    fetchCustomer: const(pure(.mock)),
    fetchPlans: pure(.mock),
    fetchPlan: const(pure(.mock)),
    fetchSubscription: const(pure(.mock))
  )
}

extension Stripe.Customer {
  public static let mock = Stripe.Customer(
    id: .init(unwrap: "cus_test")
  )
}

extension Stripe.Plan {
  public static let mock = Stripe.Plan(
    amount: .init(unwrap: 15_00),
    created: Date(timeIntervalSinceReferenceDate: 0),
    currency: .usd,
    id: .monthly,
    interval: .month,
    metadata: [:],
    name: "Monthly",
    statementDescriptor: nil
  )
}

extension Stripe.PlansEnvelope {
  public static let mock = Stripe.PlansEnvelope(
    data: [.mock],
    hasMore: false
  )
}

extension Stripe.Subscription {
  public static let mock = Stripe.Subscription(
    canceledAt: nil,
    cancelAtPeriodEnd: false,
    created: Date(timeIntervalSinceReferenceDate: 0),
    currentPeriodStart: Date(timeIntervalSinceReferenceDate: 0),
    currentPeriodEnd: Date(timeIntervalSinceReferenceDate: 60 * 60 * 24 * 30),
    customer: .init(unwrap: "cus_test"),
    endedAt: nil,
    id: .init(unwrap: "sub_test"),
    plan: .mock,
    quantity: 1,
    start: Date(timeIntervalSinceReferenceDate: 0),
    status: .active
  )
}
