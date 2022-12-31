import Cryptor
import Database
import DatabaseTestSupport
import Dependencies
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

extension DependencyValues {
  public mutating func teamYearly() {
    self.database.fetchSubscriptionTeammatesByOwnerId = { _ in [.mock] }
    self.database.fetchTeamInvites = { _ in [.mock] }
    self.stripe.fetchSubscription = { _ in .teamYearly }
    self.stripe.fetchUpcomingInvoice = { _ in update(.upcoming) { $0.amountDue = 640_00 } }
    self.stripe.fetchPaymentMethod = { _ in .mock }
  }

  public mutating func teamYearlyTeammate() {
    self.teamYearly()
    self.database.fetchSubscriptionByOwnerId = { _ in throw unit }
  }

  public mutating func individualMonthly() {
    self.database.fetchSubscriptionTeammatesByOwnerId = { _ in [.mock] }
    self.stripe.fetchSubscription = { _ in .individualMonthly }
  }
}

extension Logger {
  @available(*, deprecated)
  public static let mock = Logger(label: "co.pointfree.PointFreeTestSupport")
}

extension EnvVars {
  @available(*, deprecated)
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
      await withDependencyValues {
        $0.renderHtml = { debugRender($0) }
      } operation: {
        await io.performAsync()
      }
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
          String(
            decoding: withDependencyValues {
              $0.renderHtml = { Html.render($0) }
            } operation: {
              await io.performAsync().data
            },
            as: UTF8.self
          ),
          baseURL: nil
        )
        return webView
      }
    }
  #endif

  //
  //  #if os(macOS)
  //    @available(OSX 10.13, *)
  //    public static func ioConnWebView(size: CGSize) -> Snapshotting<
  //      IO<Conn<ResponseEnded, Data>>, NSImage
  //    > {
  //      return Snapshotting<NSView, NSImage>.image.pullback { @MainActor io in
  //        let webView = WKWebView(frame: .init(origin: .zero, size: size))
  //        await webView.loadHTMLString(
  //          String(
  //            decoding: DependencyValues.withValues {
  //              $0.renderHtml = { Html.render($0) }
  //            } operation: {
  //              io.perform().data
  //            },
  //            as: UTF8.self
  //          ),
  //          baseURL: nil
  //        )
  //        return webView
  //      }
  //    }
  //  #endif
}

public func request(to route: SiteRoute, session: Session = .loggedOut, basicAuth: Bool = false)
  -> URLRequest
{
  @Dependency(\.siteRouter) var siteRouter

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
