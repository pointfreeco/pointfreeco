import Css
import CssReset
import Either
import Foundation
import HtmlCssSupport
import HttpPipeline
import Html
import Optics
import Prelude

func sendEmail(
  from: String,
  to: String,
  subject: String,
  content: Either<String, Node>,
  domain: String = "mg.pointfree.co"
  )
  -> EitherIO<Prelude.Unit, Prelude.Unit> {

    let plain: String
    let html: String?
    switch content {

    case let .left(text):
      plain = text
      html = nil
    case let .right(node):
      plain = plainText(for: node)
      html = render(node)
    }

    let params = [
      "from": from,
      "to": to,
      "subject": subject,
      "text": plain,
      "html": html
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

func notifyUs<I>(_ conn: Conn<I, String>) -> IO<Conn<I, String>> {
  return IO {

    let email = html([
      head([style(reset)]),
      body([
        p(["Hello!"]),
        p([
          "This is an ",
          em(["HTML"]),
          " email!"
          ]),
        p(["We will notify you when we launch!"]),
        a([href(url(to: .home(signedUpSuccessfully: nil)))], ["Point-Free"])
        ])
      ])

    // Fire-and-forget to notify us that someone signed up
    _ = sendEmail(
      from: "Point-Free <brandon@pointfree.co>",
      to: conn.data,
      subject: "Thanks for signing up!",
      content: .right(email)
      )
      .run
      .perform()

    return conn
  }
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
