#if os(macOS)
import Cocoa
#endif
import Cryptor
import Database
import DatabaseTestSupport
import Either
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import GitHub
import GitHubTestSupport
import Html
import HttpPipeline
import HttpPipelineTestSupport
import Logging
import Mailgun
import Models
import ModelsTestSupport
@testable import PointFree
import PointFreeRouter
import PointFreePrelude
import Prelude
import SnapshotTesting
import Stripe
import StripeTestSupport
#if os(macOS)
import WebKit
#endif
import XCTestDynamicOverlay

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
    blogPosts: {
      XCTFail("Current.blogPosts not implemented")
      return []
    },
    cookieTransform: .plaintext,
    collections: [.mock],
    database: .failing,
    date: {
      XCTFail("Current.date not implemented")
      return Date()
    },
    envVars: .mock,
    episodes: {
      XCTFail("Current.episodes not implemented")
      return []
    },
    features: Feature.allFeatures,
    gitHub: .failing,
    logger: .mock,
    mailgun: .failing,
    renderHtml: { Html.render($0) },
    renderXml: Html._xmlRender,
    stripe: .failing,
    uuid: {
      XCTFail("Current.uuid not implemented")
      return UUID()
    }
  )

  public static let teamYearly = update(mock) {
    $0.database.fetchSubscriptionTeammatesByOwnerId = const(pure([.mock]))
    $0.database.fetchTeamInvites = const(pure([.mock]))
    $0.stripe.fetchSubscription = const(pure(.teamYearly))
    $0.stripe.fetchUpcomingInvoice = const(pure(update(.upcoming) { $0.amountDue = 640_00 }))
  }

  public static let teamYearlyTeammate = update(teamYearly) {
    $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
  }

  public static let individualMonthly = update(mock) {
    $0.database.fetchSubscriptionTeammatesByOwnerId = const(pure([.mock]))
    $0.stripe.fetchSubscription = const(pure(.individualMonthly))
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
    sendEmail: const(pure(.init(id: "deadbeef", message: "success!"))),
    validate: const(pure(.init(mailboxVerification: true)))
  )
}

extension Date {
  public static let mock = Date(timeIntervalSince1970: 1517356800)
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
      let conn = io.perform()
      Current.renderHtml = renderHtml
      Current.renderXml = renderXml
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

public func request(to route: SiteRoute, session: Session = .loggedOut, basicAuth: Bool = false) -> URLRequest {
  return request(
    with: try! pointFreeRouter.request(for: route),
    session: session,
    basicAuth: basicAuth
  )
}
