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
    fetchAuthToken: PointFree.fetchAuthToken >>> runGitHub,
    fetchEmails: PointFree.fetchEmails >>> runGitHub,
    fetchUser: PointFree.fetchUser >>> runGitHub
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

func fetchAuthToken(with code: String) -> DecodableRequest<Either<GitHub.OAuthError, GitHub.AccessToken>> {

  var request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
  request.httpMethod = "POST"
  request.httpBody = try? gitHubJsonEncoder.encode(
    [
      "client_id": Current.envVars.gitHub.clientId,
      "client_secret": Current.envVars.gitHub.clientSecret,
      "code": code,
      "accept": "json"
    ])
  request.allHTTPHeaderFields = [
    "Content-Type": "application/json",
    "Accept": "application/json"
  ]

  return DecodableRequest(rawValue: request)
}

func fetchEmails(token: GitHub.AccessToken) -> DecodableRequest<[GitHub.User.Email]> {

  return apiDataTask("user/emails", token: token)
}

func fetchUser(with token: GitHub.AccessToken) -> DecodableRequest<GitHub.User> {

  return apiDataTask("user", token: token)
}

private func apiDataTask<A>(_ path: String, token: GitHub.AccessToken) -> DecodableRequest<A> {

  return DecodableRequest(
    rawValue: URLRequest(url: URL(string: "https://api.github.com/" + path)!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "token \(token.accessToken)",
        "Accept": "application/vnd.github.v3+json"
    ]
  )
}

private func runGitHub<A>(_ gitHubRequest: DecodableRequest<A>) -> EitherIO<Error, A> {

  return jsonDataTask(with: gitHubRequest.rawValue, decoder: gitHubJsonDecoder)
}

private let gitHubJsonEncoder: JSONEncoder = { () in
  let encoder = JSONEncoder()

  if #available(OSX 10.13, *) {
    encoder.outputFormatting = [.sortedKeys]
  }

  return encoder
}()

private let gitHubJsonDecoder = JSONDecoder()
//  |> \.keyDecodingStrategy .~ .convertFromSnakeCase
