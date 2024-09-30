import EmailAddress
import Foundation
import Tagged

public struct AccessToken: Codable, Equatable, RawRepresentable {
  public var accessToken: String

  public init(accessToken: String) {
    self.accessToken = accessToken
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.accessToken = try container.decode(String.self, forKey: .accessToken)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(accessToken, forKey: .accessToken)
  }

  public init?(rawValue: String) {
    self.accessToken = rawValue
  }

  public var rawValue: String {
    accessToken
  }

  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}

public struct OAuthError: Codable, Swift.Error {
  public var description: String
  public var error: Error
  public var errorUri: String

  public init(description: String, error: Error, errorUri: String) {
    self.description = description
    self.error = error
    self.errorUri = errorUri
  }

  public enum Error: String, Codable {
    /// <https://developer.github.com/apps/managing-oauth-apps/troubleshooting-oauth-app-access-token-request-errors/#bad-verification-code>
    case badVerificationCode = "bad_verification_code"
  }

  private enum CodingKeys: String, CodingKey {
    case description
    case error
    case errorUri = "error_uri"
  }
}

public struct GitHubUser: Codable, Identifiable {
  public var createdAt: Date
  public var login: String
  public var id: Tagged<Self, Int>
  public var name: String?

  public init(
    createdAt: Date,
    login: String,
    id: ID,
    name: String?
  ) {
    self.createdAt = createdAt
    self.login = login
    self.id = id
    self.name = name
  }

  public struct Email: Codable {
    public var email: EmailAddress
    public var primary: Bool

    public init(email: EmailAddress, primary: Bool) {
      self.email = email
      self.primary = primary
    }
  }

  private enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case login
    case id
    case name
  }
}

public struct GitHubUserEnvelope: Codable {
  public var accessToken: AccessToken
  public var gitHubUser: GitHubUser

  public init(accessToken: AccessToken, gitHubUser: GitHubUser) {
    self.accessToken = accessToken
    self.gitHubUser = gitHubUser
  }
}
