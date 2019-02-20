import PointFreePrelude
import Tagged

public struct AccessToken: Codable {
  public var accessToken: String

  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}

public struct OAuthError: Codable {
  public var description: String
  public var error: Error
  public var errorUri: String

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

public struct User: Codable {
  public var id: Id
  public var name: String?

  public struct Email: Codable {
    public var email: EmailAddress
    public var primary: Bool
  }

  public typealias Id = Tagged<User, Int>
}

public struct UserEnvelope: Codable {
  public var accessToken: AccessToken
  public var gitHubUser: User

  public init(accessToken: AccessToken, gitHubUser: User) {
    self.accessToken = accessToken
    self.gitHubUser = gitHubUser
  }
}
