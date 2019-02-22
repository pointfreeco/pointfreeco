#if os(macOS)
import Cocoa
#endif
import Cryptor
import Either
import Foundation
@testable import GitHub
import Html
import HttpPipeline
import HttpPipelineTestSupport
import Logger
import Optics
@testable import PointFree
import PointFreePrelude
import Prelude
import SnapshotTesting
@testable import Stripe
#if os(macOS)
import WebKit
#endif

extension Environment {
  public static let mock = Environment(
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
    renderHtml: Html.render,
    stripe: .mock,
    uuid: { .mock }
  )

  public static let teamYearly = mock
    |> (\Environment.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([Database.User.mock]))
    |> (\Environment.database.fetchTeamInvites) .~ const(pure([Database.TeamInvite.mock]))
    |> (\Environment.stripe.fetchSubscription) .~ const(pure(Stripe.Subscription.teamYearly))
    |> (\Environment.stripe.fetchUpcomingInvoice) .~ const(pure(Stripe.Invoice.upcoming |> \.amountDue .~ 640_00))

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
  public static let mock = Logger.init(level: .debug, output: .null, error: .null)
}

extension EnvVars {
  public static var mock: EnvVars {
    return EnvVars()
      |> \.appEnv .~ EnvVars.AppEnv.testing
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
    createFeedRequestEvent: { _, _, _ in pure(unit) },
    createSubscription: { _, _ in pure(unit) },
    deleteTeamInvite: const(pure(unit)),
    fetchAdmins: unzurry(pure([])),
    fetchEmailSettingsForUserId: const(pure([.mock])),
    fetchEpisodeCredits: const(pure([])),
    fetchFreeEpisodeUsers: { pure([.mock]) },
    fetchSubscriptionById: const(pure(.some(.mock))),
    fetchSubscriptionByOwnerId: const(pure(.some(.mock))),
    fetchSubscriptionTeammatesByOwnerId: const(pure([.mock])),
    fetchTeamInvite: const(pure(.mock)),
    fetchTeamInvites: const(pure([])),
    fetchUserByGitHub: const(pure(.mock)),
    fetchUserById: const(pure(.mock)),
    fetchUsersSubscribedToNewsletter: { _, _ in pure([.mock]) },
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
    rssSalt: .init(rawValue: UUID(uuidString: "00000000-5A17-0000-0000-000000000000")!),
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

extension UUID {
  public static let mock = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
}

extension Snapshotting {
  public static var ioConn: Snapshotting<IO<Conn<ResponseEnded, Data>>, String> {
    return Snapshotting<Conn<ResponseEnded, Data>, String>.conn.pullback { io in
      let renderHtml = Current.renderHtml
      update(&Current, \.renderHtml .~ { debugRender($0) })
      let conn = io.perform()
      update(&Current, \.renderHtml .~ renderHtml)
      return conn
    }
  }

  #if os(macOS)
  @available(OSX 10.13, *)
  public static func ioConnWebView(size: CGSize) -> Snapshotting<IO<Conn<ResponseEnded, Data>>, NSImage> {
    return Snapshotting<NSView, NSImage>.image.pullback { io in
      let webView = WKWebView(frame: .init(origin: .zero, size: size))
      webView.loadHTMLString(String(decoding: io.perform().data, as: UTF8.self), baseURL: nil)
      return webView
    }
  }
  #endif
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
