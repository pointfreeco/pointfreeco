import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import UrlFormEncoding

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
  var from: String
  var to: [String]
  var cc: [String]? = nil
  var bcc: [String]? = nil
  var subject: String
  var text: String?
  var html: String?
  var testMode: Bool? = nil
  var tracking: Tracking? = nil
  var trackingClicks: TrackingClicks? = nil
  var trackingOpens: TrackingOpens? = nil
  var domain: String
}

public struct SendEmailResponse: Decodable {
  let id: String
  let message: String
}

func mailgunSend(email: Email) -> EitherIO<Prelude.Unit, SendEmailResponse> {

  let params = [
    "from": email.from,
    "to": email.to.joined(separator: ","),
    "cc": email.cc?.joined(separator: ","),
    "bcc": email.bcc?.joined(separator: ","),
    "subject": email.subject,
    "text": email.text,
    "html": email.html,
    "tracking": email.tracking?.rawValue,
    "tracking-clicks": email.trackingClicks?.rawValue,
    "tracking-opens": email.trackingOpens?.rawValue
    ]
    |> compact


  let request = URLRequest(
    url: URL(string: "https://api.mailgun.net/v3/\(AppEnvironment.current.envVars.mailgun.domain)/messages")!
    )
    |> \.httpMethod .~ "POST"
    |> \.allHTTPHeaderFields %~ attachedMailgunAuthorization
    |> \.httpBody .~ Data(urlFormEncode(value: params).utf8)

  return jsonDataTask(with: request)
    .withExcept(const(unit))
}

private func attachedMailgunAuthorization(_ headers: [String: String]?) -> [String: String]? {
  let secret = Data("api:\(AppEnvironment.current.envVars.mailgun.apiKey)".utf8).base64EncodedString()
  return (headers ?? [:])
    |> key("Authorization") .~ ("Basic " + secret) // TODO: Use key path subscript
}

// TODO: move to swift-prelude
private func compact<K, V>(_ xs: [K: V?]) -> [K: V] {
  var result = [K: V]()
  for (key, value) in xs {
    if let value = value {
      result[key] = value
    }
  }
  return result
}
