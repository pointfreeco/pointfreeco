import Either
import Foundation
import HttpPipeline
import Html
import Optics
import Prelude

func sendEmail(
  from: String,
  to: [String],
  subject: String,
  content: Either3<String, [Node], (String, [Node])>,
  domain: String = "mg.pointfree.co"
  )
  -> EitherIO<Prelude.Unit, Prelude.Unit> {

    let (plain, html): (String, String?) =
      destructure(
        content,
        { plain in (plain, nil) },
        { nodes in (plainText(for: nodes), render(nodes)) },
        second(render)
    )

    return mailgunSend(from: from, to: to, subject: subject, text: plain, html: html, domain: domain)
}

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

func mailgunSend(
  from: String,
  to: [String],
  cc: [String]? = nil,
  bcc: [String]? = nil,
  subject: String,
  text: String?,
  html: String?,
  testMode: Bool? = nil,
  tracking: Tracking? = nil,
  trackingClicks: TrackingClicks? = nil,
  trackingOpens: TrackingOpens? = nil,
  domain: String
  )
  -> EitherIO<Prelude.Unit, Prelude.Unit> {

    let params = [
      "from": from,
      "to": to.joined(separator: ","),
      "cc": cc?.joined(separator: ","),
      "bcc": bcc?.joined(separator: ","),
      "subject": subject,
      "text": text,
      "html": html,
      "tracking": tracking?.rawValue,
      "tracking-clicks": trackingClicks?.rawValue,
      "tracking-opens": trackingOpens?.rawValue
      ]
      |> compact


    let request = URLRequest(url: URL(string: "https://api.mailgun.net/v3/\(domain)/messages")!)
      |> \.httpMethod .~ "POST"
      |> \.allHTTPHeaderFields %~ attachedMailgunAuthorization
      |> \.httpBody .~ Data(urlFormEncode(value: params).utf8)

    let session = URLSession(configuration: .default)

    return .init(
      run: .init { callback in
        session.dataTask(with: request) { data, response, error in
          error == nil
            ? callback(.right(unit))
            : callback(.left(unit))
          }
          .resume()
      })
}

// TODO: move to swift-web
private func plainText(for node: Node) -> String {
  switch node {

  case .comment(_):
    return ""
  case let .document(document):
    return document.map(plainText).joined()
  case let .element(element):
    return plainText(for: element)
  case let .text(text):
    return text.string
  }
}

private func plainText(for element: Element) -> String {

  switch element.name.lowercased() {
  case "br":
    return "\n"
  case "style", "script":
    return ""
  case "b", "big", "i", "small", "tt", "abbr", "acronym",
       "cite", "code", "dfn", "em", "kbd", "strong", "samp",
       "var", "a", "bdo", "br", "img", "map", "object", "q",
       "script", "span", "sub", "sup", "button", "input", "label",
       "select", "textarea":
    return (element.content ?? []).map(plainText).joined()

  default:
    return (element.content ?? []).map(plainText).joined() + "\n"
  }
}

private func attachedMailgunAuthorization(_ headers: [String: String]?) -> [String: String]? {
  return (headers ?? [:])
    |> key("Authorization") .~ ("Basic " + Data("api:\(EnvVars.Mailgun.apiKey)".utf8).base64EncodedString())
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

// TODO: move to swift-prelude
private func destructure<A, B, C, D>(
  _ either: Either3<A, B, C>,
  _ a2d: (A) -> D,
  _ b2d: (B) -> D,
  _ c2d: (C) -> D
  )
  -> D {
    switch either {
    case let .left(a):
      return a2d(a)
    case let .right(.left(b)):
      return b2d(b)
    case let .right(.right(.left(c))):
      return c2d(c)
    }
}
