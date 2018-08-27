import Cryptor
import Either
import Foundation
import HttpPipeline
import Optics
@testable import PointFree
import Prelude

extension Environment {
  public static let mock = Environment.init(
    assets: .mock,
    blogPosts: unzurry([.mock]),
    cookieTransform: .plaintext,
    database: .mock,
    date: unzurry(.mock),
    envVars: .mock,
    episodes: unzurry(.mock),
    features: .allFeatures,
    gitHub: .mock,
    logger: .mock,
    mailgun: .mock,
    stripe: .mock
  )

  public static let teamYearly = mock
    |> (\.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([.mock]))
    |> \.database.fetchTeamInvites .~ const(pure([.mock]))
    |> \.stripe.fetchSubscription .~ const(pure(.teamYearly))

  public static let individualMonthly = mock
    |> (\.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([.mock]))
    |> \.stripe.fetchSubscription .~ const(pure(.individualMonthly))
}

extension Array where Element == Episode {
  static let mock: [Element] = [.subscriberOnly, .free]
}

extension Assets {
  static let mock = Assets(
    brandonImgSrc: "",
    stephenImgSrc: "",
    emailHeaderImgSrc: "",
    pointersEmailHeaderImgSrc: ""
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

extension Mailgun {
  public static let mock = Mailgun(
    sendEmail: const(pure(.init(id: "deadbeef", message: "success!")))
  )
}

extension Database {
  public static let mock = Database(
    addUserIdToSubscriptionId: { _, _ in pure(unit) },
    createSubscription: { _, _ in pure(unit) },
    deleteTeamInvite: const(pure(unit)),
    fetchAdmins: unzurry(pure([])),
    fetchEmailSettingsForUserId: const(pure([.mock])),
    fetchEpisodeCredits: const(pure([])),
    fetchFreeEpisodeUsers: { pure([.mock]) },
    fetchSubscriptionById: const(pure(.some(.mock))),
    fetchSubscriptionByOwnerId: const(pure(.some(.mock))),
    fetchSubscriptionTeammatesByOwnerId: const(pure([])),
    fetchTeamInvite: const(pure(.mock)),
    fetchTeamInvites: const(pure([])),
    fetchUserByGitHub: const(pure(.mock)),
    fetchUserById: const(pure(.mock)),
    fetchUsersSubscribedToNewsletter: const(pure([.mock])),
    fetchUsersToWelcome: const(pure([.mock])),
    incrementEpisodeCredits: const(pure([])),
    insertTeamInvite: { _, _ in pure(.mock) },
    migrate: unzurry(pure(unit)),
    redeemEpisodeCredit: { _, _ in pure(unit) },
    registerUser: { _, _ in pure(.some(.mock)) },
    removeTeammateUserIdFromSubscriptionId: { _, _ in pure(unit) },
    updateStripeSubscription: const(pure(.mock)),
    updateUser: { _, _, _, _, _ in pure(unit) },
    upsertUser: { _, _ in pure(.some(.mock)) }
  )
}

extension Database.User {
  public static let mock = Database.User(
    email: "hello@pointfree.co",
    episodeCreditCount: 0,
    gitHubUserId: 1,
    gitHubAccessToken: "deadbeef",
    id: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    isAdmin: false,
    name: "Blob",
    subscriptionId: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
  )

  public static let newUser = mock
    |> \.episodeCreditCount .~ 1
    |> \.subscriptionId .~ nil

  public static let owner = mock

  public static let teammate = mock
    |> \.id .~ .init(rawValue: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)

  public static let nonSubscriber = mock
    |> \.subscriptionId .~ nil
}

extension Database.Subscription {
  public static let mock = Database.Subscription(
    id: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    stripeSubscriptionId: Stripe.Subscription.mock.id,
    stripeSubscriptionStatus: .active,
    userId: Database.User.mock.id
  )

  public static let canceled = mock
    |> \.stripeSubscriptionStatus .~ .canceled

  public static let pastDue = mock
    |> \.stripeSubscriptionStatus .~ .pastDue
}

extension Database.TeamInvite {
  public static let mock = Database.TeamInvite(
    createdAt: .mock,
    email: "blob@pointfree.co",
    id: .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!),
    inviterUserId: .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
  )
}

extension Database.EmailSetting {
  public static let mock = Database.EmailSetting(
    newsletter: .newEpisode,
    userId: .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
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
    fetchAuthToken: const(pure(pure(.mock))),
    fetchEmails: const(pure([.mock])),
    fetchUser: const(pure(.mock))
  )
}

extension GitHub.User.Email {
  public static let mock = GitHub.User.Email(
    email: "hello@pointfree.co",
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
    id: 1,
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
    createSubscription: { _, _, _, _ in pure(.mock) },
    fetchCustomer: const(pure(.mock)),
    fetchInvoice: const(pure(.mock(charge: .right(.mock)))),
    fetchInvoices: const(pure(.mock([.mock(charge: .right(.mock))]))),
    fetchPlans: pure(.mock([.mock])),
    fetchPlan: const(pure(.mock)),
    fetchSubscription: const(pure(.mock)),
    invoiceCustomer: const(pure(.mock(charge: .right(.mock)))),
    updateCustomer: { _, _ in pure(.mock) },
    updateCustomerExtraInvoiceInfo: { _, _ in pure(.mock) },
    updateSubscription: { _, _, _, _ in pure(.mock) },
    js: ""
  )
}

extension Stripe.Card {
  public static let mock = Stripe.Card(
    brand: .visa,
    customer: "cus_test",
    expMonth: 1,
    expYear: 2020,
    id: "card_test",
    last4: "4242"
  )
}

extension Stripe.Charge {
  public static let mock = Stripe.Charge(
    amount: 17_00,
    id: "ch_test",
    source: .mock
  )
}

extension Stripe.Customer {
  public static let mock = Stripe.Customer(
    businessVatId: nil,
    defaultSource: "card_test",
    id: "cus_test",
    metadata: [:],
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

extension Stripe.Event where T == Either<Stripe.Invoice, Stripe.Subscription> {
  public static var invoice: Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>> {
    return .init(
      data: .init(object: .left(.mock(charge: .left("ch_test")))),
      id: "evt_test",
      type: .invoicePaymentFailed
    )
  }
}

extension Stripe.Invoice {
  public static func mock(charge: Either<Stripe.Charge.Id, Stripe.Charge>?) -> Stripe.Invoice {
    return Stripe.Invoice(
      amountDue: 0_00,
      amountPaid: 17_00,
      charge: charge,
      closed: true,
      customer: "cus_test",
      date: .mock,
      discount: nil,
      id: "in_test",
      lines: .mock([.mock]),
      number: "0000000-0000",
      periodStart: .mock,
      periodEnd: Date.mock.addingTimeInterval(60 * 60 * 24 * 30),
      subscription: "sub_test",
      subtotal: 17_00,
      total: 17_00
    )
  }
}

extension Stripe.LineItem {
  public static let mock = Stripe.LineItem(
    amount: 17_00,
    description: nil,
    id: "ii_test",
    plan: .mock,
    quantity: 1,
    subscription: "sub_test"
  )
}

extension Stripe.ListEnvelope {
  public static func mock(_ xs: [A]) -> Stripe.ListEnvelope<A> {
    return .init(
      data: xs,
      hasMore: false
    )
  }
}

extension Stripe.Plan {
  public static let mock = Stripe.Plan(
    amount: 17_00,
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
    |> \.amount .~ 170_00
    |> \.id .~ .individualYearly
    |> \.name .~ "Individual Yearly"

  public static let teamMonthly = mock
    |> \.amount .~ 16_00
    |> \.id .~ .teamMonthly
    |> \.name .~ "Team Monthly"

  public static let teamYearly = mock
    |> \.amount .~ 160_00
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
    customer: .right(.mock),
    discount: nil,
    endedAt: nil,
    id: "sub_test",
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

  public static let canceled = canceling
    |> \.canceledAt .~ Date(timeInterval: -60 * 60 * 24 * 30, since: .mock)
    |> \.currentPeriodEnd .~ Date(timeInterval: -60 * 60 * 24 * 30, since: .mock)
    |> \.currentPeriodStart .~ Date(timeInterval: -60 * 60 * 24 * 60, since: .mock)
    |> \.status .~ .canceled
}

extension Stripe.Subscription.Discount {
  public static let mock = Stripe.Subscription.Discount(coupon: .mock)
}

extension Stripe.Subscription.Discount.Coupon {
  public static let mock = Stripe.Subscription.Discount.Coupon(
    amountOff: nil,
    id: "coupon-deadbeef",
    name: "Student Discount",
    percentOff: 50,
    valid: true
  )
}

extension Stripe.Subscription.Item {
  public static let mock = Stripe.Subscription.Item(
    created: .mock,
    id: "si_test",
    plan: .mock,
    quantity: 1
  )
}

extension SubscribeData {
  public static let individualMonthly = SubscribeData(
    coupon: nil,
    pricing: .init(billing: .monthly, quantity: 1),
    token: "stripe-deadbeef",
    vatNumber: ""
  )

  public static let individualYearly = SubscribeData(
    coupon: nil,
    pricing: .init(billing: .yearly, quantity: 1),
    token: "stripe-deadbeef",
    vatNumber: ""
  )

  public static func teamYearly(quantity: Int) -> SubscribeData {
    return .init(
      coupon: nil,
      pricing: .init(billing: .yearly, quantity: quantity),
      token: "stripe-deadbeef",
      vatNumber: ""
    )
  }
}

extension Session {
  public static let loggedOut = empty

  public static let loggedIn = loggedOut
    |> \.userId .~ Database.User.mock.id
}

public func request(
  with baseRequest: URLRequest,
  session: Session = .loggedOut,
  basicAuth: Bool = false
  ) -> URLRequest {

  var request = baseRequest

  // NB: This `httpBody` dance is necessary due to a strange Foundation bug in which the body gets cleared
  //     if you edit fields on the request.
  //     See: https://bugs.swift.org/browse/SR-6687
  let httpBody = request.httpBody
  request.httpBody = httpBody
  request.httpMethod = request.httpMethod?.uppercased()

  if basicAuth {
    let username = Current.envVars.basicAuth.username
    let password = Current.envVars.basicAuth.password
    request.allHTTPHeaderFields = request.allHTTPHeaderFields ?? [:]
    request.allHTTPHeaderFields?["Authorization"] =
      "Basic " + Data("\(username):\(password)".utf8).base64EncodedString()
  }

  guard
    let sessionData = try? cookieJsonEncoder.encode(session),
    let sessionCookie = String(data: sessionData, encoding: .utf8)
    else { return request }

  request.allHTTPHeaderFields = (request.allHTTPHeaderFields ?? [:])
    .merging(["Cookie": "pf_session=\(sessionCookie)"], uniquingKeysWith: { $1 })

  return request
}

public func request(to route: Route, session: Session = .loggedOut, basicAuth: Bool = false) -> URLRequest {
  return request(
    with: router.request(for: route, base: URL(string: "http://localhost:8080"))!,
    session: session,
    basicAuth: basicAuth
  )
}
