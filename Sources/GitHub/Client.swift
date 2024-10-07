import AsyncHTTPClient
import DecodableRequest
import Dependencies
import DependenciesMacros
import Either
import Foundation
import FoundationPrelude
import Logging
import Tagged

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@DependencyClient
public struct Client {
  /// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
  public var fetchAuthToken: (_ code: String) async throws -> AuthTokenResponse

  /// Fetches a GitHub user's emails.
  public var fetchEmails: (_ accessToken: GitHubAccessToken) async throws -> [GitHubUser.Email]

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (_ accessToken: GitHubAccessToken) async throws -> GitHubUser

  @DependencyEndpoint(method: "fetchUser")
  public var fetchUserByUserID: (
    _ id: GitHubUser.ID,
    _ accessToken: GitHubAccessToken
  ) async throws -> GitHubUser

  public struct AuthTokenResponse: Codable {
    public var accessToken: String
    public init(_ accessToken: String) {
      self.accessToken = accessToken
    }
    public var toGitHubAccessToken: GitHubAccessToken {
      GitHubAccessToken(rawValue: accessToken)
    }
    private enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
    }
  }
}

extension Client {
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias Secret = Tagged<(Self, secret: ()), String>

  public init(clientId: ID, clientSecret: Secret) {
    self.init(
      fetchAuthToken: { code in
        try await jsonDataTask(
          with: fetchGitHubAuthToken(clientId: clientId, clientSecret: clientSecret, code: code),
          decoder: gitHubJsonDecoder
        )
      },
      fetchEmails: {
        try await jsonDataTask(with: fetchGitHubEmails(token: $0), decoder: gitHubJsonDecoder)
      },
      fetchUser: {
        try await jsonDataTask(with: fetchGitHubUser(with: $0), decoder: gitHubJsonDecoder)
      },
      fetchUserByUserID: { userID, accessToken in
        try await jsonDataTask(with: fetchGitHubUser(id: userID, with: accessToken), decoder: gitHubJsonDecoder)
      }
    )
  }
}

func fetchGitHubAuthToken(
  clientId: Client.ID,
  clientSecret: Client.Secret,
  code: String
) -> DecodableHTTPClientRequest<Client.AuthTokenResponse> {
  var request = HTTPClientRequest(url: "https://github.com/login/oauth/access_token")
  request.method = .POST
  request.headers.add(name: "accept", value: "application/json")
  request.headers.add(name: "content-type", value: "application/json")
  request.body = .bytes(
    .init(
      data: try! gitHubJsonEncoder.encode([
        "client_id": clientId.rawValue,
        "client_secret": clientSecret.rawValue,
        "code": code,
        "accept": "json",
      ])
    )
  )
  return DecodableHTTPClientRequest(request)
}

func fetchGitHubEmails(token: GitHubAccessToken) -> DecodableHTTPClientRequest<[GitHubUser.Email]> {
  apiDataTask("user/emails", token: token)
}

func fetchGitHubUser(
  with token: GitHubAccessToken
) -> DecodableHTTPClientRequest<GitHubUser> {
  apiDataTask("user", token: token)
}

func fetchGitHubUser(
  id: GitHubUser.ID,
  with token: GitHubAccessToken
) -> DecodableHTTPClientRequest<GitHubUser> {
  apiDataTask("user/\(id)", token: token)
}

private func apiDataTask<A>(
  _ path: String,
  token: GitHubAccessToken
) -> DecodableHTTPClientRequest<A> {
  var request = HTTPClientRequest(url: "https://api.github.com/\(path)")
  request.headers.add(name: "accept", value: "application/vnd.github.v3+json")
  request.headers.add(name: "authorization", value: "token \(token.rawValue)")
  return DecodableHTTPClientRequest(rawValue: request)
}

private let gitHubJsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  encoder.outputFormatting = [.sortedKeys]
  return encoder
}()

private let gitHubJsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  return decoder
}()

extension Client: TestDependencyKey {
  public static let testValue = Client()
}

extension DependencyValues {
  public var gitHub: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}
