import Either
import Foundation
import Html
import HttpPipeline
import Optics
import Prelude
import UrlFormEncoding

public struct Mailgun {
  public var createNewsletterRoute: (Database.EmailSetting.Newsletter) -> EitherIO<Prelude.Unit, Prelude.Unit>
  public var deleteRoute: (String) -> EitherIO<Prelude.Unit, Prelude.Unit>
  public var fetchRoutes: () -> EitherIO<Prelude.Unit, RoutesEnvelope>
  public var sendEmail: (Email) -> EitherIO<Prelude.Unit, SendEmailResponse>
  public var updateNewsletterRoute: (String, Database.EmailSetting.Newsletter) -> EitherIO<Prelude.Unit, Prelude.Unit>

  public static let live = Mailgun(
    createNewsletterRoute: createRoute(newsletter:),
    deleteRoute: hole,
    fetchRoutes: PointFree.fetchRoutes,
    sendEmail: mailgunSend,
    updateNewsletterRoute: hole
  )

  public struct Route: Codable {
    public let description: String
    public let id: String
  }

  public struct RoutesEnvelope: Codable {
    public let items: [Route]
    public let totalCount: Int

    private enum CodingKeys: String, CodingKey {
      case items
      case totalCount = "total_count"
    }
  }

  public struct SendEmailResponse: Decodable {
    public let id: String
    public let message: String
  }
}

public typealias EmailAddress = Tagged<Email, String>

enum Tracking: String {
  case no
  case yes
}

enum TrackingClicks: String {
  case yes
  case no
  case htmlOnly = "htmlonly"
}

enum TrackingOpens: String {
  case yes
  case no
  case htmlOnly = "htmlonly"
}

public struct Email {
  var from: EmailAddress
  var to: [EmailAddress]
  var cc: [EmailAddress]? = nil
  var bcc: [EmailAddress]? = nil
  var subject: String
  var text: String?
  var html: String?
  var testMode: Bool? = nil
  var tracking: Tracking? = nil
  var trackingClicks: TrackingClicks? = nil
  var trackingOpens: TrackingOpens? = nil
  var domain: String
  var headers: [(String, String)] = []
}

func mailgunSend(email: Email) -> EitherIO<Prelude.Unit, Mailgun.SendEmailResponse> {

  var params: [String: String] = [:]
  params["from"] = email.from.unwrap
  params["to"] = email.to.map(^\.unwrap).joined(separator: ",")
  params["cc"] = email.cc.map(map(^\.unwrap) >>> joined(separator: ","))
  params["bcc"] = email.bcc.map(map(^\.unwrap) >>> joined(separator: ","))
  params["subject"] = email.subject
  params["text"] = email.text
  params["html"] = email.html
  params["tracking"] = email.tracking?.rawValue
  params["tracking-clicks"] = email.trackingClicks?.rawValue
  params["tracking-opens"] = email.trackingOpens?.rawValue
  email.headers.forEach { key, value in
    params["h:\(key)"] = value
  }

  let request = URLRequest(
    url: URL(string: "https://api.mailgun.net/v3/\(AppEnvironment.current.envVars.mailgun.domain)/messages")!
    )
    |> \.httpMethod .~ "POST"
    |> \.allHTTPHeaderFields %~ attachedMailgunAuthorization
    |> \.httpBody .~ Data(urlFormEncode(value: params).utf8)

  return jsonDataTask(with: request)
    .withExcept(const(unit))
}

private func createRoute(newsletter: Database.EmailSetting.Newsletter) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  var params: [String: String] = [:]
  params["priority"] = "0"
  params["description"] = routeDescription(for: newsletter)
  params["expression"] = unsubscribeEmail(for: newsletter)
  params["action"] = forwardAction(for: newsletter)

  let request = URLRequest(
    url: URL(string: "https://api.mailgun.net/v3/routes")!
    )
    |> \.httpMethod .~ "POST"
    |> \.allHTTPHeaderFields %~ attachedMailgunAuthorization
    |> \.httpBody .~ Data(urlFormEncode(value: params).utf8)

  return dataTask(with: request)
    .bimap(const(unit), const(unit))
}

private func fetchRoutes() -> EitherIO<Prelude.Unit, Mailgun.RoutesEnvelope> {

  let request = URLRequest(
    url: URL(string: "https://api.mailgun.net/v3/routes")!
    )
    |> \.httpMethod .~ "GET"
    |> \.allHTTPHeaderFields %~ attachedMailgunAuthorization

  return jsonDataTask(with: request)
    .withExcept(const(unit))
}

private func attachedMailgunAuthorization(_ headers: [String: String]?) -> [String: String]? {
  let secret = Data("api:\(AppEnvironment.current.envVars.mailgun.apiKey)".utf8).base64EncodedString()
  return (headers ?? [:])
    |> key("Authorization") .~ ("Basic " + secret) // TODO: Use key path subscript
}

private let generatedToken = "Generated for Newsletters"

func routeDescription(for newsletter: Database.EmailSetting.Newsletter) -> String {
  return "[\(generatedToken)] Unsubscribe \(newsletter.rawValue)"
}

private func unsubscribeEmail(for newsletter: Database.EmailSetting.Newsletter) -> String {
  return "unsubscribe-\(newsletter.rawValue)@pointfree.co"
}

private func forwardAction(for newsletter: Database.EmailSetting.Newsletter) -> String {
  return "forward(\"" + url(to: .expressUnsubscribeReply) + "\")"
}
