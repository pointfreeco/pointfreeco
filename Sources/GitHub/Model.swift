import PointFreePrelude
import Tagged

public struct AccessToken: Codable {
  public private(set) var accessToken: String

  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}

public struct OAuthError: Codable {
  public private(set) var description: String
  public private(set) var error: Error
  public private(set) var errorUri: String

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
  public private(set) var id: Id
  public private(set) var name: String?

  public struct Email: Codable {
    public private(set) var email: EmailAddress
    public private(set) var primary: Bool
  }

  public typealias Id = Tagged<User, Int>
}

public struct UserEnvelope: Codable {
  public private(set) var accessToken: AccessToken
  public private(set) var gitHubUser: User

  public init(accessToken: AccessToken, gitHubUser: User) {
    self.accessToken = accessToken
    self.gitHubUser = gitHubUser
  }
}
