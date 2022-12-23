import DecodableRequest
import Either
import Foundation
import FoundationPrelude
import Logging
import Tagged

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct Client {
  /// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
  public var fetchAuthToken: (String) async throws -> Either<OAuthError, AccessToken>

  /// Fetches a GitHub user's emails.
  public var fetchEmails: (AccessToken) async throws -> [GitHubUser.Email]

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (AccessToken) async throws -> GitHubUser

  public init(
    fetchAuthToken: @escaping (String) async throws -> Either<OAuthError, AccessToken>,
    fetchEmails: @escaping (AccessToken) async throws -> [GitHubUser.Email],
    fetchUser: @escaping (AccessToken) async throws -> GitHubUser
  ) {
    self.fetchAuthToken = fetchAuthToken
    self.fetchEmails = fetchEmails
    self.fetchUser = fetchUser
  }
}

extension Client {
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias Secret = Tagged<(Self, secret: ()), String>

  public init(clientId: ID, clientSecret: Secret, logger: Logger?) {
    self.init(
      fetchAuthToken: {
        try await runGitHub(logger)(fetchGitHubAuthToken(clientId: clientId, clientSecret: clientSecret)($0))
      },
      fetchEmails: { try await runGitHub(logger)(fetchGitHubEmails(token: $0)) },
      fetchUser: { try await runGitHub(logger)(fetchGitHubUser(with: $0)) }
    )
  }
}

func fetchGitHubAuthToken(
  clientId: Client.ID, clientSecret: Client.Secret
)
  -> (String)
  -> DecodableRequest<Either<OAuthError, AccessToken>>
{

  return { code in
    var request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
    request.httpMethod = "POST"
    request.httpBody = try? gitHubJsonEncoder.encode(
      [
        "client_id": clientId.rawValue,
        "client_secret": clientSecret.rawValue,
        "code": code,
        "accept": "json",
      ])
    request.allHTTPHeaderFields = [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]

    return DecodableRequest(rawValue: request)
  }
}

func fetchGitHubEmails(token: AccessToken) -> DecodableRequest<[GitHubUser.Email]> {
  return apiDataTask("user/emails", token: token)
}

internal func fetchGitHubUser(with token: AccessToken) -> DecodableRequest<GitHubUser> {
  return apiDataTask("user", token: token)
}

private func apiDataTask<A>(_ path: String, token: AccessToken) -> DecodableRequest<A> {
  var request = URLRequest(url: URL(string: "https://api.github.com/" + path)!)
  request.addValue("token \(token.accessToken)", forHTTPHeaderField: "Authorization")
  request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
  return DecodableRequest(rawValue: request)
}

private func runGitHub<A>(
  _ logger: Logger?
) -> (DecodableRequest<A>) async throws -> A {
  return { gitHubRequest in
    try await jsonDataTask(with: gitHubRequest.rawValue, decoder: gitHubJsonDecoder, logger: logger)
      .performAsync()
  }
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
