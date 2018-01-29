import Either
import Foundation
import Optics
import Prelude

public struct GitHub {
  /// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
  public var fetchAuthToken: (String) -> EitherIO<Error, AccessToken>

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (AccessToken) -> EitherIO<Error, User>

  static let live = GitHub(
    fetchAuthToken: PointFree.fetchAuthToken,
    fetchUser: PointFree.fetchUser
  )

  public struct AccessToken: Codable {
    public let accessToken: String

    enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
    }
  }

  public struct User: Codable {
    public private(set) var avatarUrl: String
    public private(set) var email: EmailAddress
    public private(set) var id: Id
    public private(set) var name: String

    public typealias Id = Tagged<User, Int>

    private enum CodingKeys: String, CodingKey {
      case avatarUrl = "avatar_url"
      case email
      case id
      case name
    }
  }

  public struct UserEnvelope: Codable {
    public private(set) var accessToken: AccessToken
    public private(set) var gitHubUser: User
  }
}

private func fetchAuthToken(with code: String) -> EitherIO<Error, GitHub.AccessToken> {

  let request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
    |> \.httpMethod .~ "POST"
    |> \.httpBody .~ (try? JSONEncoder().encode(
      [
        "client_id": AppEnvironment.current.envVars.gitHub.clientId,
        "client_secret": AppEnvironment.current.envVars.gitHub.clientSecret,
        "code": code,
        "accept": "json"
      ]))
    |> \.allHTTPHeaderFields .~ [
      "Content-Type": "application/json",
      "Accept": "application/json"
  ]

  return jsonDataTask(with: request)
}

private func fetchUser(with accessToken: GitHub.AccessToken) -> EitherIO<Error, GitHub.User> {

  let request = URLRequest(url: URL(string: "https://api.github.com/user")!)
    |> \.allHTTPHeaderFields .~ [
      "Authorization": "token \(accessToken.accessToken)",
      "Accept": "application/vnd.github.v3+json"
  ]

  return jsonDataTask(with: request)
}
