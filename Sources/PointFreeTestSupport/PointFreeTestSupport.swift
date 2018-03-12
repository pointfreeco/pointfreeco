import Cryptor
import Either
import Foundation
import HttpPipeline
import Optics
@testable import PointFree
import Prelude

extension Environment {
  public static let mock = Environment(
    cookieTransform: .plaintext,
    database: .mock,
    date: { .mock },
    envVars: .mock,
    episodes: { [.mock] },
    gitHub: .mock,
    logger: .mock,
    mailgun: .mock,
    stripe: .mock
  )

  public static let teamYearly = mock
    |> \.database.fetchSubscriptionTeammatesByOwnerId .~ const(pure([.mock]))
    |> \.database.fetchTeamInvites .~ const(pure([.mock]))
    |> \.stripe.fetchSubscription .~ const(pure(.teamYearly))
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

extension Mailgun {
  public static let mock = Mailgun(
    sendEmail: const(pure(.init(id: "deadbeef", message: "success!")))
  )
}

extension Database {
  public static let mock = Database(
    addEpisodeCredit: { _, _ in hole() },
    addUserIdToSubscriptionId: { _, _ in pure(unit) },
    createSubscription: { _, _ in pure(unit) },
    deleteTeamInvite: const(pure(unit)),
    insertTeamInvite: { _, _ in pure(.mock) },
    fetchEmailSettingsForUserId: const(pure([.mock])),
    fetchEpisodeCredits: const(pure([])),
    fetchSubscriptionById: const(pure(.some(.mock))),
    fetchSubscriptionByOwnerId: const(pure(.some(.mock))),
    fetchSubscriptionTeammatesByOwnerId: const(pure([])),
    fetchTeamInvite: const(pure(.mock)),
    fetchTeamInvites: const(pure([])),
    fetchUserByEmail: const(pure(.mock)),
    fetchUserByGitHub: const(pure(.mock)),
    fetchUserById: const(pure(.mock)),
    fetchUsersSubscribedToNewsletter: const(pure([.mock])),
    registerUser: { _, _ in pure(.some(.mock)) },
    removeTeammateUserIdFromSubscriptionId: { _, _ in pure(unit) },
    updateStripeSubscription: const(pure(.mock)),
    updateUser: { _, _, _, _, _ in pure(unit) },
    upsertUser: { _, _ in pure(.some(.mock)) },
    migrate: { pure(unit) }
  )
}

extension Database.User {
  public static let mock = Database.User(
    email: .init(unwrap: "hello@pointfree.co"),
    episodeCreditCount: 0,
    gitHubUserId: .init(unwrap: 1),
    gitHubAccessToken: "deadbeef",
    id: .init(unwrap: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    isAdmin: false,
    name: "Blob",
    subscriptionId: .init(unwrap: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
  )

  public static let owner = mock

  public static let teammate = mock
    |> \.id .~ .init(unwrap: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
}

extension Database.Subscription {
  public static let mock = Database.Subscription(
    id: .init(unwrap: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    stripeSubscriptionId: Stripe.Subscription.mock.id,
    stripeSubscriptionStatus: .active,
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

extension Database.EmailSetting {
  public static let mock = Database.EmailSetting(
    newsletter: .newEpisode,
    userId: .init(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
  )
}

extension Database.EpisodeCredit {
  public static let mock = Database.EpisodeCredit(
    episodeSequence: 1,
    userId: Database.User.mock.id
  )
}

extension Date {
  public static let mock = Date(timeIntervalSince1970: 1517356800)
}

extension GitHub {
  public static let mock = GitHub(
    fetchAuthToken: const(pure(.mock)),
    fetchEmails: const(pure([.mock])),
    fetchUser: const(pure(.mock))
  )
}

extension GitHub.User.Email {
  public static let mock = GitHub.User.Email(
    email: EmailAddress(unwrap: "hello@pointfree.co"),
    primary: true
  )
}

extension GitHub.AccessToken {
  public static let mock = GitHub.AccessToken(
    accessToken: "deadbeef"
  )
}

extension GitHub.User {
  public static let mock = GitHub.User(
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

extension Pricing {
  public static let mock = `default`

  public static let individualMonthly = mock
    |> \.billing .~ .monthly
    |> \.quantity .~ 1

  public static let individualYearly = mock
    |> \.billing .~ .yearly
    |> \.quantity .~ 1

  public static let teamMonthly = mock
    |> \.billing .~ .monthly
    |> \.quantity .~ 4

  public static let teamYearly = mock
    |> \.billing .~ .yearly
    |> \.quantity .~ 4
}

extension Stripe {
  public static let mock = Stripe(
    cancelSubscription: const(pure(.canceling)),
    createCustomer: { _, _, _ in pure(.mock) },
    createSubscription: { _, _, _ in pure(.mock) },
    fetchCustomer: const(pure(.mock)),
    fetchPlans: pure(.mock([.mock])),
    fetchPlan: const(pure(.mock)),
    fetchSubscription: const(pure(.mock)),
    invoiceCustomer: const(pure(.mock)),
    updateCustomer: { _, _ in pure(.mock) },
    updateSubscription: { _, _, _, _ in pure(.mock) },
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

extension Stripe.Error {
  public static let mock = Stripe.Error(
    message: "Your card has insufficient funds."
  )
}

extension Stripe.ErrorEnvelope {
  public static let mock = Stripe.ErrorEnvelope(
    error: .mock
  )
}

extension Stripe.Event where T == Stripe.Invoice {
  public static var mock: Stripe.Event<Stripe.Invoice> {
    return .init(
      data: .init(object: .mock),
      id: .init(unwrap: "evt_test"),
      type: .invoicePaymentFailed
    )
  }
}

extension Stripe.Invoice {
  public static let mock = Stripe.Invoice(
    amountDue: .init(unwrap: 17_00),
    customer: .init(unwrap: "cus_test"),
    id: .init(unwrap: "in_test"),
    subscription: .init(unwrap: "sub_test")
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
    amount: .init(unwrap: 17_00),
    created: .mock,
    currency: .usd,
    id: .individualMonthly,
    interval: .month,
    metadata: [:],
    name: "Individual Monthly",
    statementDescriptor: nil
  )

  public static let individualMonthly = mock

  public static let individualYearly = mock
    |> \.amount .~ .init(unwrap: 170_00)
    |> \.id .~ .individualYearly
    |> \.name .~ "Individual Yearly"

  public static let teamMonthly = mock
    |> \.amount .~ .init(unwrap: 16_00)
    |> \.id .~ .teamMonthly
    |> \.name .~ "Team Monthly"

  public static let teamYearly = mock
    |> \.amount .~ .init(unwrap: 160_00)
    |> \.id .~ .teamYearly
    |> \.name .~ "Team Yearly"
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

  public static let individualMonthly = mock
    |> \.plan .~ .individualMonthly
    |> \.quantity .~ 1

  public static let individualYearly = mock
    |> \.plan .~ .individualYearly
    |> \.quantity .~ 1

  public static let teamMonthly = mock
    |> \.plan .~ .teamMonthly
    |> \.quantity .~ 4

  public static let teamYearly = mock
    |> \.plan .~ .teamYearly
    |> \.quantity .~ 4

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

extension SubscribeData {
  public static let individualMonthly = SubscribeData(
    pricing: .init(billing: .monthly, quantity: 1),
    token: .init(unwrap: "stripe-deadbeef"),
    vatNumber: ""
  )

  public static let individualYearly = SubscribeData(
    pricing: .init(billing: .yearly, quantity: 1),
    token: .init(unwrap: "stripe-deadbeef"),
    vatNumber: ""
  )

  public static func teamYearly(quantity: Int) -> SubscribeData {
    return .init(
      pricing: .init(billing: .yearly, quantity: quantity),
      token: .init(unwrap: "stripe-deadbeef"),
      vatNumber: ""
    )
  }
}

extension Session {
  public static let loggedOut = empty

  public static let loggedIn = loggedOut
    |> \.userId .~ Database.User.mock.id
}

public func request(to route: Route, session: Session = .loggedOut) -> URLRequest {
  var request = router.request(for: route, base: URL(string: "http://localhost:8080"))!

  // NB: This `httpBody` dance is necessary due to a strange Foundation bug in which the body gets cleared
  //     if you edit fields on the request.
  //     See: https://bugs.swift.org/browse/SR-6687
  let httpBody = request.httpBody
  request.httpBody = httpBody
  request.httpMethod = request.httpMethod?.uppercased()

  guard
    let sessionData = try? cookieJsonEncoder.encode(session),
    let sessionCookie = String(data: sessionData, encoding: .utf8)
    else { return request }

  request.allHTTPHeaderFields = (request.allHTTPHeaderFields ?? [:])
    .merging(["Cookie": "pf_session=\(sessionCookie)"], uniquingKeysWith: { $1 })

  return request
}
