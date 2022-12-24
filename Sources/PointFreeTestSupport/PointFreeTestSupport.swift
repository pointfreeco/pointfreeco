import Cryptor
import Database
import DatabaseTestSupport
import Either
import Foundation
import GitHub
import GitHubTestSupport
import Html
import HttpPipeline
import HttpPipelineTestSupport
import Logging
import Mailgun
import Models
import ModelsTestSupport
import OrderedCollections
import PointFreePrelude
import PointFreeRouter
import Prelude
import SnapshotTesting
import Stripe
import StripeTestSupport
import URLRouting
import XCTestDynamicOverlay

@testable import PointFree

#if os(macOS)
  import Cocoa
#endif
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
#if os(macOS)
  import WebKit
#endif

extension Environment {
  public static let mock = Environment(
    assets: .mock,
    blogPosts: { [.mock] },
    cookieTransform: .plaintext,
    collections: [.mock],
    database: .some(.mock),
    date: unzurry(.mock),
    envVars: .mock,
    episodes: unzurry(.mock),
    features: Feature.allFeatures,
    gitHub: .some(.mock),
    logger: .mock,
    mailgun: .mock,
    renderHtml: { Html.render($0) },
    renderXml: Html._xmlRender,
    stripe: .some(.mock),
    uuid: unzurry(.mock)
  )

  public static let failing = Self(
    assets: .mock,
    blogPosts: unimplemented("Current.blogPosts", placeholder: []),
    cookieTransform: .plaintext,
    collections: [.mock],
    database: .failing,
    date: unimplemented("Current.date", placeholder: Date()),
    envVars: .mock,
    episodes: unimplemented("Current.episodes", placeholder: []),
    features: Feature.allFeatures,
    gitHub: .failing,
    logger: .mock,
    mailgun: .failing,
    renderHtml: { Html.render($0) },
    renderXml: Html._xmlRender,
    stripe: .failing,
    uuid: unimplemented("Current.uuid", placeholder: UUID())
  )

  public static let teamYearly = update(mock) {
    $0.database.fetchSubscriptionTeammatesByOwnerId = { _ in [.mock] }
    $0.database.fetchTeamInvites = { _ in [.mock] }
    $0.stripe.fetchSubscription = { _ in .teamYearly }
    $0.stripe.fetchUpcomingInvoice = { _ in update(.upcoming) { $0.amountDue = 640_00 } }
    $0.stripe.fetchPaymentMethod = { _ in .mock }
  }

  public static let teamYearlyTeammate = update(teamYearly) {
    $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
  }

  public static let individualMonthly = update(mock) {
    $0.database.fetchSubscriptionTeammatesByOwnerId = { _ in [.mock] }
    $0.stripe.fetchSubscription = { _ in .individualMonthly }
  }
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
  public static let mock = Logger(label: "co.pointfree.PointFreeTestSupport")
}

extension EnvVars {
  public static var mock: EnvVars {
    return update(EnvVars()) {
      $0.appEnv = EnvVars.AppEnv.testing
      $0.postgres.databaseUrl = "postgres://pointfreeco:@localhost:5432/pointfreeco_test"
    }
  }
}

extension Mailgun.Client {
  public static let mock = Mailgun.Client(
    appSecret: "deadbeefdeadbeefdeadbeefdeadbeef",
    sendEmail: { _ in SendEmailResponse(id: "deadbeef", message: "success!") },
    validate: { _ in Validation(mailboxVerification: true) }
  )
}

extension Date {
  public static let mock = Date(timeIntervalSince1970: 1_517_356_800)
}

extension Session {
  public static let loggedOut = empty

  public static func loggedIn(as user: Models.User) -> Session {
    return update(loggedOut) {
      $0.user = .standard(user.id)
    }
  }

  public static let loggedIn = Session.loggedIn(as: .mock)
}

extension UUID {
  public static let mock = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
}

extension Snapshotting {
  public static var ioConn: Snapshotting<IO<Conn<ResponseEnded, Data>>, String> {
    return Snapshotting<Conn<ResponseEnded, Data>, String>.conn.pullback { io in
      let renderHtml = Current.renderHtml
      let renderXml = Current.renderXml
      Current.renderHtml = { debugRender($0) }
      Current.renderXml = { _debugXmlRender($0) }
      let conn = await io.performAsync()
      Current.renderHtml = renderHtml
      Current.renderXml = renderXml
      return conn
    }
  }

  #if os(macOS)
    @available(OSX 10.13, *)
    public static func ioConnWebView(size: CGSize) -> Snapshotting<
      IO<Conn<ResponseEnded, Data>>, NSImage
    > {
      return Snapshotting<NSView, NSImage>.image.pullback { @MainActor io in
        let webView = WKWebView(frame: .init(origin: .zero, size: size))
        await webView.loadHTMLString(
          String(decoding: io.performAsync().data, as: UTF8.self),
          baseURL: nil
        )
        return webView
      }
    }
  #endif
}

public func request(to route: SiteRoute, session: Session = .loggedOut, basicAuth: Bool = false)
  -> URLRequest
{
  var headers: OrderedDictionary<String, [String?]> = [:]

  if basicAuth {
    let authString = "\(Current.envVars.basicAuth.username):\(Current.envVars.basicAuth.password)"
    headers["Authorization"] = ["Basic \(Data(authString.utf8).base64EncodedString())"]
  }

  if let sessionData = try? cookieJsonEncoder.encode(session),
    let sessionCookie = String(data: sessionData, encoding: .utf8)
  {
    headers["Cookie"] = ["pf_session=\(sessionCookie)"]
  }

  return
    try! siteRouter
    .baseRequestData(URLRequestData(headers: headers))
    .request(for: route)
}
