import EmailAddress
import Foundation
import Tagged

public typealias GitHubAccessToken = Tagged<((), accessToken: ()), String>

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

public struct Repo: Codable {
  public var commit: Commit

  public init(commit: Commit) {
    self.commit = commit
  }

  public struct Commit: Codable {
    public typealias SHA = Tagged<Self, String>
    public var sha: SHA

    public init(sha: SHA) {
      self.sha = sha
    }
  }
}
