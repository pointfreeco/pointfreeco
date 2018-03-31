import Either
import Foundation
import Optics
import Prelude

public struct GitHub {
  /// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
  public var fetchAuthToken: (String) -> EitherIO<Error, Either<OAuthError, AccessToken>>

  /// Fetches a GitHub user's emails.
  public var fetchEmails: (AccessToken) -> EitherIO<Error, [GitHub.User.Email]>

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (AccessToken) -> EitherIO<Error, User>

  static let live = GitHub(
    fetchAuthToken: PointFree.fetchAuthToken,
    fetchEmails: PointFree.fetchEmails,
    fetchUser: PointFree.fetchUser
  )

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
  }
}

private func fetchAuthToken(with code: String) -> EitherIO<Error, Either<GitHub.OAuthError, GitHub.AccessToken>> {

  var request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
  request.httpMethod = "POST"
  request.httpBody = try? JSONEncoder().encode(
    [
      "client_id": AppEnvironment.current.envVars.gitHub.clientId,
      "client_secret": AppEnvironment.current.envVars.gitHub.clientSecret,
      "code": code,
      "accept": "json"
    ])
  request.allHTTPHeaderFields = [
    "Content-Type": "application/json",
    "Accept": "application/json"
  ]

  return jsonDataTask(with: request, decoder: gitHubJsonDecoder)
}

private func fetchEmails(token: GitHub.AccessToken) -> EitherIO<Error, [GitHub.User.Email]> {

  return apiDataTask("user/emails", token: token)
}

private func fetchUser(with token: GitHub.AccessToken) -> EitherIO<Error, GitHub.User> {

  return apiDataTask("user", token: token)
}

private func apiDataTask<A: Decodable>(_ path: String, token: GitHub.AccessToken) -> EitherIO<Error, A> {

  let request = URLRequest(url: URL(string: "https://api.github.com/" + path)!)
    |> \.allHTTPHeaderFields .~ [
      "Authorization": "token \(token.accessToken)",
      "Accept": "application/vnd.github.v3+json"
  ]

  return jsonDataTask(with: request, decoder: gitHubJsonDecoder)
}

private let gitHubJsonDecoder = JSONDecoder()
//  |> \.keyDecodingStrategy .~ .convertFromSnakeCase
