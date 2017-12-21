import Foundation
import Either
@testable import PointFree
import Optics
import Prelude

extension Environment {
  public static let mock = Environment(
    airtableStuff: const(const(pure(unit))),
    database: .mock,
    date: { .mock },
    envVars: .mock,
    gitHub: .mock,
    logger: .mock,
    sendEmail: const(pure(.init(id: "deadbeef", message: "success!"))),
    stripe: .mock
  )
}

extension Logger {
  public static let mock = Logger(level: .debug, logger: { _ in })
}

extension EnvVars {
  public static var mock: EnvVars {
    return EnvVars()
      |> \.postgres.databaseUrl .~ "postgres://pointfreeco:@localhost:5432/pointfreeco_test"
  }
}

extension Database {
  public static let mock = Database(
    addUserIdToSubscriptionId: { _, _ in pure(unit) },
    createSubscription: { _, _ in pure(unit) },
    deleteTeamInvite: const(pure(unit)),
    insertTeamInvite: { _, _ in pure(.mock) },
    fetchSubscriptionById: const(pure(.some(.mock))),
    fetchSubscriptionByOwnerId: const(pure(.some(.mock))),
    fetchSubscriptionTeammatesByOwnerId: const(pure([.mock])),
    fetchTeamInvite: const(pure(.mock)),
    fetchTeamInvites: const(pure([.mock])),
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

extension Database.Subscription {
  public static let mock = Database.Subscription(
    id: .init(unwrap: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    stripeSubscriptionId: Stripe.Subscription.mock.id,
    userId: Database.User.mock.id
  )
}

extension Database.TeamInvite {
  public static let mock = Database.TeamInvite(
    createdAt: Date(timeIntervalSince1970: 1234567890),
    email: .init(unwrap: "blob@pointfree.co"),
    id: .init(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!),
    inviterUserId: .init(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
  )
}

extension Date {
  public static let mock = Date(timeIntervalSince1970: 1517356800)
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
    avatarUrl: "http://www.blob.com/pic.jpg",
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
    createSubscription: { _, _, _ in pure(.mock) },
    fetchCustomer: const(pure(.mock)),
    fetchPlans: pure(.mock),
    fetchPlan: const(pure(.mock)),
    fetchSubscription: const(pure(.mock))
  )
}

extension Stripe.Customer {
  public static let mock = Stripe.Customer(
    defaultSource: .init(unwrap: "card_test"),
    id: .init(unwrap: "cus_test"),
    sources: .init(
      data: [
        .init(
          brand: .visa,
          customer: .init(unwrap: "cus_test"),
          expMonth: 1,
          expYear: 2020,
          id: .init(unwrap: "card_test"),
          last4: "4242"
        )
      ],
      hasMore: false,
      totalCount: 1
    )
  )
}

extension Stripe.Plan {
  public static let mock = Stripe.Plan(
    amount: .init(unwrap: 15_00),
    created: Date(timeIntervalSinceReferenceDate: 0),
    currency: .usd,
    id: .individualMonthly,
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
    customer: .mock,
    endedAt: nil,
    id: .init(unwrap: "sub_test"),
    plan: .mock,
    quantity: 1,
    start: Date(timeIntervalSinceReferenceDate: 0),
    status: .active
  )
}
