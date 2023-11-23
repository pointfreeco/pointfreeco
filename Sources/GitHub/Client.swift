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
  public var fetchAuthToken: (_ code: String) async throws -> Either<OAuthError, AccessToken>

  /// Fetches a GitHub user's emails.
  public var fetchEmails: (_ accessToken: AccessToken) async throws -> [GitHubUser.Email]

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (_ accessToken: AccessToken) async throws -> GitHubUser
}

extension Client {
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias Secret = Tagged<(Self, secret: ()), String>

  public init(clientId: ID, clientSecret: Secret) {
    @Dependency(\.logger) var logger
    self.init(
      fetchAuthToken: { code in
        try await jsonDataTask(
          with: fetchGitHubAuthToken(clientId: clientId, clientSecret: clientSecret)(code),
          decoder: gitHubJsonDecoder
        )
      },
      fetchEmails: {
        try await jsonDataTask(with: fetchGitHubEmails(token: $0), decoder: gitHubJsonDecoder)
      },
      fetchUser: {
        try await jsonDataTask(with: fetchGitHubUser(with: $0), decoder: gitHubJsonDecoder)
      }
    )
  }
}

func fetchGitHubAuthToken(
  clientId: Client.ID, clientSecret: Client.Secret
)
  -> (String) throws
  -> DecodableHTTPClientRequest<Either<OAuthError, AccessToken>>
{

  return { code in
    var request = HTTPClientRequest(url: "https://github.com/login/oauth/access_token")
    request.method = .POST
    request.headers.add(name: "accept", value: "application/json")
    request.headers.add(name: "content-type", value: "application/json")
    request.body = .bytes(
      .init(
        data: try gitHubJsonEncoder.encode([
          "client_id": clientId.rawValue,
          "client_secret": clientSecret.rawValue,
          "code": code,
          "accept": "json",
        ])
      )
    )
    return DecodableHTTPClientRequest(request)
  }
}

func fetchGitHubEmails(token: AccessToken) -> DecodableHTTPClientRequest<[GitHubUser.Email]> {
  apiDataTask("user/emails", token: token)
}

func fetchGitHubUser(
  with token: AccessToken
) -> DecodableHTTPClientRequest<GitHubUser> {
  apiDataTask("user", token: token)
}

private func apiDataTask<A>(_ path: String, token: AccessToken) -> DecodableHTTPClientRequest<A> {
  var request = HTTPClientRequest(url: "https://api.github.com/\(path)")
  request.headers.add(name: "accept", value: "application/vnd.github.v3+json")
  request.headers.add(name: "authorization", value: "token \(token.accessToken)")
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
