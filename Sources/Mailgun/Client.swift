import Either
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpPipeline
import Logging
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
  public var validate: (EmailAddress) -> EitherIO<Error, Validation>

  public struct Validation: Codable {
    public var mailboxVerification: Bool

    public enum CodingKeys: String, CodingKey {
      case mailboxVerification = "mailbox_verification"
    }

    public init(mailboxVerification: Bool) {
      self.mailboxVerification = mailboxVerification
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.mailboxVerification = Bool(try container.decode(String.self, forKey: .mailboxVerification)) ?? false
    }
  }

  public init(
    appSecret: AppSecret,
    sendEmail: @escaping (Email) -> EitherIO<Error, SendEmailResponse>,
    validate: @escaping (EmailAddress) -> EitherIO<Error, Validation>) {
    self.appSecret = appSecret
    self.sendEmail = sendEmail
    self.validate = validate
  }

  public init(
    apiKey: ApiKey,
    appSecret: AppSecret,
    domain: Client.Domain,
    logger: Logger) {
    self.appSecret = appSecret

    self.sendEmail = { email in
      mailgunSend(email: email, domain: domain)
        |> runMailgun(apiKey: apiKey, logger: logger)
    }
    self.validate = mailgunValidate >>> runMailgun(apiKey: apiKey, logger: logger)
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
    request.url = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.url(relativeTo: baseUrl)
    return request
  }
}

private func runMailgun<A>(
  apiKey: Client.ApiKey,
  logger: Logger
  ) -> (DecodableRequest<A>?) -> EitherIO<Error, A> {

  return { mailgunRequest in
    guard let baseUrl = URL(string: "https://api.mailgun.net")
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
  case get([String: Any])
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

private func mailgunRequest<A>(_ path: String, _ method: Method = .get([:])) -> DecodableRequest<A> {

  var components = URLComponents(url: URL(string: path)!, resolvingAgainstBaseURL: false)!
  if case let .get(params) = method {
    components.queryItems = params.map { key, value in
      URLQueryItem(name: key, value: "\(value)")
    }
  }

  return DecodableRequest(
    rawValue: URLRequest(url: components.url!)
      |> attachMethod(method)
  )
}

private func mailgunSend(email: Email, domain: Client.Domain) -> DecodableRequest<SendEmailResponse> {
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

  return mailgunRequest("v3/\(domain.rawValue)/messages", Method.post(params))
}

private func mailgunValidate(email: EmailAddress) -> DecodableRequest<Client.Validation> {
  return mailgunRequest(
    "v3/address/private/validate",
    .get([
      "address": email.rawValue,
      "mailbox_verification": true
      ])
  )
}

public struct MailgunError: Codable, Swift.Error {
  public init() {
  }
}

private let jsonDecoder = JSONDecoder()
  |> \.dateDecodingStrategy .~ .secondsSince1970
