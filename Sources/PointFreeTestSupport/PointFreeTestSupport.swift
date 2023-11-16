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
import InlineSnapshotTesting
import Logging
import Mailgun
import Models
import ModelsTestSupport
import OrderedCollections
import PointFreePrelude
import PointFreeRouter
import Prelude
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

public enum PointFreeTestConfiguration {
  @TaskLocal public static var middleware = siteMiddleware
}

public func assertRequest(
  _ conn: Conn<StatusLineOpen, Prelude.Unit>,
  request: (() -> String)? = nil,
  response: (() -> String)? = nil,
  file: StaticString = #filePath,
  function: StaticString = #function,
  line: UInt = #line,
  column: UInt = #column
) async {
  let conn = await PointFreeTestConfiguration.middleware(conn)

  await assertInlineSnapshot(
    of: conn.request,
    as: .raw,
    message: """
      Request output (\(actualPrefix)) differed from expected output (\(expectedPrefix)). \
      Difference: …
      """,
    syntaxDescriptor: InlineSnapshotSyntaxDescriptor(
      trailingClosureLabel: "request",
      trailingClosureOffset: 0
    ),
    matches: request,
    file: file,
    function: function,
    line: line,
    column: column
  )
  await assertInlineSnapshot(
    of: conn.response,
    as: .response,
    message: """
      Response output (\(actualPrefix)) differed from expected output (\(expectedPrefix)). \
      Difference: …
      """,
    syntaxDescriptor: InlineSnapshotSyntaxDescriptor(
      trailingClosureLabel: "response",
      trailingClosureOffset: 1
    ),
    matches: response,
    file: file,
    function: function,
    line: line,
    column: column
  )
}

private let expectedPrefix = "\u{2212}"
private let actualPrefix = "+"
private let prefix = "\u{2007}"

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

  public mutating func failing() {
    self.database = Database.Client()
    self.gitHub = GitHub.Client()
    self.mailgun = Mailgun.Client(appSecret: "deadbeef")
    self.stripe = Stripe.Client(js: "")
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
  #if os(macOS)
    @available(OSX 10.13, *)
    public static func connWebView(
      size: CGSize
    ) -> Snapshotting<Conn<ResponseEnded, Data>, NSImage> {
      var snapshotting = Snapshotting<NSView, NSImage>.image
        .pullback { @MainActor (conn: Conn<ResponseEnded, Data>) -> NSView in
          @Dependency(\.renderHtml) var renderHtml

          let webView = WKWebView(frame: .init(origin: .zero, size: size))
          webView.loadHTMLString(String(decoding: conn.data, as: UTF8.self), baseURL: nil)
          return webView
        }

      snapshotting.snapshot = { [snapshot = snapshotting.snapshot] value in
        try await withDependencies {
          $0.renderHtml = { Html.render($0) }
        } operation: {
          try await snapshot { try await value() }
        }
      }

      return snapshotting
    }
  #endif
}

public func request(
  to route: SiteRoute, session: Session = .loggedOut, basicAuth addBasicAuth: Bool = false
)
  -> URLRequest
{
  @Dependency(\.envVars.basicAuth) var basicAuth
  @Dependency(\.siteRouter) var siteRouter

  var headers: OrderedDictionary<String, [String?]> = [:]

  if addBasicAuth {
    let authString = "\(basicAuth.username):\(basicAuth.password)"
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
