#if os(macOS)
import Cocoa
#endif
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
import Logger
import Mailgun
import Models
import ModelsTestSupport
import Optics
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

extension Environment {
  public static let mock = Environment(
    assets: .mock,
    blogPosts: { [.mock] },
    cookieTransform: .plaintext,
    database: .some(.mock),
    date: unzurry(.mock),
    envVars: .mock,
    episodes: unzurry(.mock),
    features: .allFeatures,
    gitHub: .some(.mock),
    logger: .mock,
    mailgun: .mock,
    renderHtml: Html.render,
    stripe: .some(.mock),
    uuid: unzurry(.mock)
  )

  public static let teamYearly = mock
    |> (\Environment.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([.mock]))
    |> (\Environment.database.fetchTeamInvites) .~ const(pure([.mock]))
    |> (\Environment.stripe.fetchSubscription) .~ const(pure(.teamYearly))
    |> (\Environment.stripe.fetchUpcomingInvoice) .~ const(pure(.upcoming |> \.amountDue .~ 640_00))

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

extension Mailgun.Client {
  public static let mock = Mailgun.Client(
    appSecret: "deadbeefdeadbeefdeadbeefdeadbeef",
    sendEmail: const(pure(.init(id: "deadbeef", message: "success!")))
  )
}

extension Date {
  public static let mock = Date(timeIntervalSince1970: 1517356800)
}

extension Session {
  public static let loggedOut = empty

  public static let loggedIn = loggedOut
    |> \.userId .~ Models.User.mock.id
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
    with: pointFreeRouter.request(for: route)!,
    session: session,
    basicAuth: basicAuth
  )
}
