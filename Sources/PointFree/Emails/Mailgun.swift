import Either
import Foundation
import Html
import HttpPipeline
import Optics
import Prelude
import UrlFormEncoding

public struct Mailgun {
  public var sendEmail: (Email) -> EitherIO<Error, SendEmailResponse>

  public static let live = Mailgun(
    sendEmail: mailgunSend
  )

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

private func mailgunSend(email: Email) -> EitherIO<Error, Mailgun.SendEmailResponse> {

  var params: [String: String] = [:]
  params["from"] = email.from.rawValue
  params["to"] = email.to.map(^\.rawValue).joined(separator: ",")
  params["cc"] = email.cc.map(map(^\.rawValue) >>> joined(separator: ","))
  params["bcc"] = email.bcc.map(map(^\.rawValue) >>> joined(separator: ","))
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
    url: URL(string: "https://api.mailgun.net/v3/\(Current.envVars.mailgun.domain)/messages")!
    )
    |> \.httpMethod .~ "POST"
    |> \.allHTTPHeaderFields %~ attachedMailgunAuthorization
    |> \.httpBody .~ Data(urlFormEncode(value: params).utf8)

  return jsonDataTask(with: request)
}

private func attachedMailgunAuthorization(_ headers: [String: String]?) -> [String: String]? {
  let secret = Data("api:\(Current.envVars.mailgun.apiKey)".utf8).base64EncodedString()
  return (headers ?? [:])
    |> key("Authorization") .~ ("Basic " + secret) // TODO: Use key path subscript
}

func unsubscribeEmail(
  fromUserId userId: Database.User.Id,
  andNewsletter newsletter: Database.EmailSetting.Newsletter,
  boundary: String = "--"
  ) -> EmailAddress? {

  guard let payload = encrypted(
    text: "\(userId.rawValue.uuidString)\(boundary)\(newsletter.rawValue)",
    secret: Current.envVars.appSecret
    ) else { return nil }

  return .init(rawValue: "unsub-\(payload)@pointfree.co")
}

func userIdAndNewsletter(
  fromUnsubscribeEmail email: EmailAddress,
  boundary: String = "--"
  ) -> (Database.User.Id, Database.EmailSetting.Newsletter)? {

  let payload = email.rawValue
    .components(separatedBy: "unsub-")
    .last
    .flatMap { $0.split(separator: "@").first }
    .map(String.init)

  return payload
    .flatMap { decrypted(text: $0, secret: Current.envVars.appSecret) }
    .map { $0.components(separatedBy: boundary) }
    .flatMap {
      tuple
        <¢> $0.first.flatMap(UUID.init(uuidString:) >=> Database.User.Id.init)
        <*> $0.last.flatMap(Database.EmailSetting.Newsletter.init(rawValue:))
  }
}
