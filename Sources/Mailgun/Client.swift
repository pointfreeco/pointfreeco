import Either
import Foundation
import HttpPipeline
import Logger
import Models
import Optics
import PointFreePrelude
import Prelude
import Tagged
import UrlFormEncoding

public struct Client {
  public typealias ApiKey = Tagged<(Client, apiKey: ()), String>
  public typealias Domain = Tagged<(Client, domain: ()), String>

  private let appSecret: AppSecret

  public var sendEmail: (Email) -> EitherIO<Error, SendEmailResponse>

  public init(
    appSecret: AppSecret,
    sendEmail: @escaping (Email) -> EitherIO<Error, SendEmailResponse>) {
    self.appSecret = appSecret
    self.sendEmail = sendEmail
  }

  public init(
    apiKey: ApiKey,
    appSecret: AppSecret,
    domain: Domain,
    logger: Logger) {
    self.appSecret = appSecret

    self.sendEmail = mailgunSend >>> runMailgun(apiKey: apiKey, domain: domain, logger: logger)
  }

  /// Constructs the email address that users can email in order to unsubscribe from a particular newsletter.
  public func unsubscribeEmail(
    fromUserId userId: User.Id,
    andNewsletter newsletter: EmailSetting.Newsletter,
    boundary: String = "--"
    ) -> EmailAddress? {

    guard let payload = encrypted(
      text: "\(userId.rawValue.uuidString)\(boundary)\(newsletter.rawValue)",
      secret: self.appSecret.rawValue
      ) else { return nil }

    return .init(rawValue: "unsub-\(payload)@pointfree.co")
  }

  // Decodes an unsubscribe email address into the user and newsletter that is represented by the address.
  public func userIdAndNewsletter(
    fromUnsubscribeEmail email: EmailAddress,
    boundary: String = "--"
    ) -> (User.Id, EmailSetting.Newsletter)? {

    let payload = email.rawValue
      .components(separatedBy: "unsub-")
      .last
      .flatMap { $0.split(separator: "@").first }
      .map(String.init)

    return payload
      .flatMap { decrypted(text: $0, secret: self.appSecret.rawValue) }
      .map { $0.components(separatedBy: boundary) }
      .flatMap { components in
        guard
          let userId = components.first.flatMap(UUID.init(uuidString:)).flatMap(User.Id.init),
          let newsletter = components.last.flatMap(EmailSetting.Newsletter.init(rawValue:))
          else { return nil }

        return (userId, newsletter)
    }
  }

  public func verify(payload: MailgunForwardPayload, with apiKey: ApiKey) -> Bool {
    let digest = hexDigest(
      value: "\(payload.timestamp)\(payload.token)",
      asciiSecret: apiKey.rawValue
    )
    return payload.signature == digest
  }
}

private func setBaseUrl(_ baseUrl: URL) -> (URLRequest) -> URLRequest {
  return { request in
    var request = request
    request.url = baseUrl.appendingPathComponent(request.url?.relativePath ?? "")
    return request
  }
}

private func runMailgun<A>(
  apiKey: Client.ApiKey,
  domain: Client.Domain,
  logger: Logger
  ) -> (DecodableRequest<A>?) -> EitherIO<Error, A> {

  return { mailgunRequest in
    guard let baseUrl = URL(string: "https://api.mailgun.net/v3/\(domain)")
      else { return throwE(unit) }
    guard var mailgunRequest = mailgunRequest
      else { return throwE(unit) }

    mailgunRequest.rawValue = mailgunRequest.rawValue
      |> setBaseUrl(baseUrl)
      |> attachBasicAuth(username: "api", password: apiKey.rawValue)

    return dataTask(with: mailgunRequest.rawValue, logger: logger)
      .map(first)
      .flatMap { data in
        .wrap {
          do {
            return try jsonDecoder.decode(A.self, from: data)
          } catch {
            throw (try? jsonDecoder.decode(MailgunError.self, from: data))
              ?? JSONError.error(String(decoding: data, as: UTF8.self), error) as Error
          }
        }
    }
  }
}

private enum Method {
  case get
  case post([String: Any])
  case delete([String: String])
}

private func attachMethod(_ method: Method) -> (URLRequest) -> URLRequest {
  switch method {
  case .get:
    return \.httpMethod .~ "GET"
  case let .post(params):
    return (\.httpMethod .~ "POST")
      <> attachFormData(params)
  case let .delete(params):
    return (\.httpMethod .~ "DELETE")
      <> attachFormData(params)
  }
}

private func mailgunRequest<A>(_ path: String, _ method: Method = .get) -> DecodableRequest<A> {
  return DecodableRequest(
    rawValue: URLRequest(url: URL(string: "/" + path)!)
      |> attachMethod(method)
  )
}

private func mailgunSend(email: Email) -> DecodableRequest<SendEmailResponse> {
  var params: [String: String] = [:]
  params["from"] = email.from.rawValue
  params["to"] = email.to.map { $0.rawValue }.joined(separator: ",")
  params["cc"] = email.cc?.map { $0.rawValue }.joined(separator: ",")
  params["bcc"] = email.bcc?.map { $0.rawValue }.joined(separator: ",")
  params["subject"] = email.subject
  params["text"] = email.text
  params["html"] = email.html
  params["tracking"] = email.tracking?.rawValue
  params["tracking-clicks"] = email.trackingClicks?.rawValue
  params["tracking-opens"] = email.trackingOpens?.rawValue
  email.headers.forEach { key, value in
    params["h:\(key)"] = value
  }

  return mailgunRequest("messages", Method.post(params))
}

public struct MailgunError: Codable, Swift.Error {
  public init() {
  }
}

private let jsonDecoder = JSONDecoder()
  |> \.dateDecodingStrategy .~ .secondsSince1970
