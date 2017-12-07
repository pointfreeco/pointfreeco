import Either
import Foundation
import Optics
import Prelude

public struct GitHub {
  /// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
  var fetchAuthToken: (String) -> EitherIO<Prelude.Unit, AccessToken>

  /// Fetches a GitHub user from an access token.
  var fetchUser: (AccessToken) -> EitherIO<Prelude.Unit, User>

  static let live = GitHub(
    fetchAuthToken: PointFree.fetchAuthToken,
    fetchUser: PointFree.fetchUser
  )

  public struct AccessToken: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
    }
  }

  public struct User: Codable {
    let email: EmailAddress
    let id: Int
    let name: String
  }

  public struct UserEnvelope: Codable {
    let accessToken: AccessToken
    let gitHubUser: User
  }
}

private func fetchAuthToken(with code: String) -> EitherIO<Prelude.Unit, GitHub.AccessToken> {

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
    .map(tap(AppEnvironment.current.logger.debug))
    .withExcept(tap(AppEnvironment.current.logger.error) >>> const(unit))
}

private func fetchUser(with accessToken: GitHub.AccessToken) -> EitherIO<Prelude.Unit, GitHub.User> {

  let request = URLRequest(url: URL(string: "https://api.github.com/user")!)
    |> \.allHTTPHeaderFields .~ [
      "Authorization": "token \(accessToken.accessToken)",
      "Accept": "application/vnd.github.v3+json"
  ]

  return jsonDataTask(with: request)
    .map(tap(AppEnvironment.current.logger.debug))
    .withExcept(tap(AppEnvironment.current.logger.error) >>> const(unit))
}

private let session = URLSession(configuration: .default)
