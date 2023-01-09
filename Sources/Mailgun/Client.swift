import DecodableRequest
import Dependencies
import Either
import EmailAddress
import Foundation
import FoundationPrelude
import HttpPipeline
import Logging
import LoggingDependencies
import Models
import Tagged
import UrlFormEncoding

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct Client {
  public typealias ApiKey = Tagged<(Self, apiKey: ()), String>
  public typealias Domain = Tagged<(Self, domain: ()), String>

  private let appSecret: AppSecret

  public var sendEmail: (Email) async throws -> SendEmailResponse
  public var validate: (EmailAddress) async throws -> Validation

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
      self.mailboxVerification =
        Bool(try container.decode(String.self, forKey: .mailboxVerification)) ?? false
    }
  }

  public init(
    appSecret: AppSecret,
    sendEmail: @escaping (Email) async throws -> SendEmailResponse,
    validate: @escaping (EmailAddress) async throws -> Validation
  ) {
    self.appSecret = appSecret
    self.sendEmail = sendEmail
    self.validate = validate
  }

  public init(
    apiKey: ApiKey,
    appSecret: AppSecret,
    domain: Client.Domain
  ) {
    self.appSecret = appSecret

    self.sendEmail = { email in
      try await runMailgun(apiKey: apiKey)(
        mailgunSend(email: email, domain: domain))
    }
    self.validate = { emailAddress in
      try await runMailgun(apiKey: apiKey)(mailgunValidate(email: emailAddress))
    }
  }

  /// Constructs the email address that users can email in order to unsubscribe from a particular newsletter.
  public func unsubscribeEmail(
    fromUserId userId: User.ID,
    andNewsletter newsletter: EmailSetting.Newsletter,
    boundary: String = "--"
  ) -> EmailAddress? {

    guard
      let payload = encrypted(
        text: "\(userId.rawValue.uuidString)\(boundary)\(newsletter.rawValue)",
        secret: self.appSecret.rawValue,
        nonce: [0x30, 0x9D, 0xF8, 0xA2, 0x72, 0xA7, 0x4D, 0x37, 0xB9, 0x02, 0xDF, 0x4F]
      )
    else { return nil }

    return .init(rawValue: "unsub-\(payload)@pointfree.co")
  }

  // Decodes an unsubscribe email address into the user and newsletter that is represented by the address.
  public func userIdAndNewsletter(
    fromUnsubscribeEmail email: EmailAddress,
    boundary: String = "--"
  ) -> (User.ID, EmailSetting.Newsletter)? {

    let payload = email.rawValue
      .components(separatedBy: "unsub-")
      .last
      .flatMap { $0.split(separator: "@").first }
      .map(String.init)

    return
      payload
      .flatMap { decrypted(text: $0, secret: self.appSecret.rawValue) }
      .map { $0.components(separatedBy: boundary) }
      .flatMap { components in
        guard
          let userId = components.first.flatMap(UUID.init(uuidString:)).flatMap(
            User.ID.init(rawValue:)),
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

extension URLRequest {
  fileprivate mutating func set(baseUrl: URL) {
    self.url = URLComponents(url: self.url!, resolvingAgainstBaseURL: false)?.url(
      relativeTo: baseUrl)
  }
}

private func runMailgun<A>(
  apiKey: Client.ApiKey
) async throws -> (DecodableRequest<A>?) async throws -> A {

  return { mailgunRequest in
    guard let baseUrl = URL(string: "https://api.mailgun.net")
    else { throw MailgunError() }
    guard var mailgunRequest = mailgunRequest
    else { throw MailgunError() }

    mailgunRequest.rawValue.set(baseUrl: baseUrl)
    mailgunRequest.rawValue.attachBasicAuth(username: "api", password: apiKey.rawValue)

    return try await dataTask(with: mailgunRequest.rawValue)
      .map { data, _ in data }
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
      .performAsync()
  }
}

private func mailgunRequest<A>(_ path: String, _ method: FoundationPrelude.Method = .get([:]))
  -> DecodableRequest<A>
{

  var components = URLComponents(url: URL(string: path)!, resolvingAgainstBaseURL: false)!
  if case let .get(params) = method {
    components.queryItems = params.map { key, value in
      URLQueryItem(name: key, value: "\(value)")
    }
  }

  var request = URLRequest(url: components.url!)
  request.attach(method: method)
  return DecodableRequest(rawValue: request)
}

private func mailgunSend(email: Email, domain: Client.Domain) -> DecodableRequest<SendEmailResponse>
{
  var params: [String: String] = [:]
  params["from"] = email.from.rawValue
  params["to"] = email.to.map(\.rawValue).joined(separator: ",")
  params["cc"] = email.cc?.map(\.rawValue).joined(separator: ",")
  params["bcc"] = email.bcc?.map(\.rawValue).joined(separator: ",")
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
      "mailbox_verification": true,
    ])
  )
}

public struct MailgunError: Codable, Swift.Error {
  public init() {
  }
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  return decoder
}()

extension Client: TestDependencyKey {
  public static let testValue: Client = .failing
}

extension DependencyValues {
  public var mailgun: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}
