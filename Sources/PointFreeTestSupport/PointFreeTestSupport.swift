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
    fetchUsersSubscribedToNewEpisodeEmail: { pure([.mock]) },
    removeTeammateUserIdFromSubscriptionId: { _, _ in pure(unit) },
    updateUser: { _, _, _ in pure(unit) },
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
    createdAt: .mock,
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
    cancelSubscription: const(pure(.canceling)),
    createCustomer: { _, _ in pure(.mock) },
    createSubscription: { _, _, _ in pure(.mock) },
    fetchCustomer: const(pure(.mock)),
    fetchPlans: pure(.mock([.mock])),
    fetchPlan: const(pure(.mock)),
    fetchSubscription: const(pure(.mock)),
    reactivateSubscription: const(pure(.mock)),
    updateSubscription: { _, _, _ in pure(.mock) },
    js: ""
  )
}

extension Stripe.Card {
  public static let mock = Stripe.Card(
    brand: .visa,
    customer: .init(unwrap: "cus_test"),
    expMonth: 1,
    expYear: 2020,
    id: .init(unwrap: "card_test"),
    last4: "4242"
  )
}

extension Stripe.Customer {
  public static let mock = Stripe.Customer(
    defaultSource: .init(unwrap: "card_test"),
    id: .init(unwrap: "cus_test"),
    sources: .mock([.mock])
  )
}

extension Stripe.ListEnvelope {
  public static func mock(_ xs: [A]) -> Stripe.ListEnvelope<A> {
    return .init(
      data: xs,
      hasMore: false,
      totalCount: xs.count
    )
  }
}

extension Stripe.Plan {
  public static let mock = Stripe.Plan(
    amount: .init(unwrap: 15_00),
    created: .mock,
    currency: .usd,
    id: .individualMonthly,
    interval: .month,
    metadata: [:],
    name: "Monthly",
    statementDescriptor: nil
  )
}

extension Stripe.Subscription {
  public static let mock = Stripe.Subscription(
    canceledAt: nil,
    cancelAtPeriodEnd: false,
    created: .mock,
    currentPeriodStart: .mock,
    currentPeriodEnd: Date(timeInterval: 60 * 60 * 24 * 30, since: .mock),
    customer: .mock,
    endedAt: nil,
    id: .init(unwrap: "sub_test"),
    items: .mock([.mock]),
    plan: .mock,
    quantity: 1,
    start: .mock,
    status: .active
  )

  public static let canceling = mock
    |> \.cancelAtPeriodEnd .~ true

  public static let canceled = mock
    |> \.canceledAt .~ Date(timeInterval: -60 * 60 * 24 * 30, since: .mock)
    |> \.currentPeriodEnd .~ Date(timeInterval: -60 * 60 * 24 * 30, since: .mock)
    |> \.currentPeriodStart .~ Date(timeInterval: -60 * 60 * 24 * 60, since: .mock)
    |> \.status .~ .canceled
}

extension Stripe.Subscription.Item {
  public static let mock = Stripe.Subscription.Item(
    created: .mock,
    id: .init(unwrap: "si_test"),
    plan: .mock,
    quantity: 1
  )
}

public func authedRequest(to urlString: String) -> URLRequest {
  let sessionCookie = """
  be847b5f12f9571a96252587105c91f788704838959a4818df9555a7dbb636e0\
  9146d686873dfde259849eb38151c9f448d718ff57b50f22d67cc9c37c9acca2\
  b8da4c3e919a230d2b2d4222dedc4e9c354d84975c9e5f532503e6be65314e30\
  0f74e793d154bf8f3c85054ae8df44717e856dc441f24a070cad129b4072a87a
  """

  return URLRequest(url: URL(string: urlString)!)
    |> \.allHTTPHeaderFields .~ [
      "Cookie": "pf_session=\(sessionCookie)",
      "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
  ]
}
