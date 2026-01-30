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

  /// Fetches info for a repo branch.
  public var fetchBranch:
    (_ owner: String, _ repo: String, _ branch: String, _ token: GitHubAccessToken) async throws ->
      Repo

  /// Fetches a GitHub user's emails.
  public var fetchEmails: (_ accessToken: GitHubAccessToken) async throws -> [GitHubUser.Email]

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (_ accessToken: GitHubAccessToken) async throws -> GitHubUser

  @DependencyEndpoint(method: "fetchUser")
  public var fetchUserByUserID:
    (
      _ id: GitHubUser.ID,
      _ accessToken: GitHubAccessToken
    ) async throws -> GitHubUser

  /// Fetches a zipball of a given repo.
  public var fetchZipball: (
    _ owner: String,
    _ repo: String,
    _ ref: Repo.Commit.SHA,
    _ token: GitHubAccessToken
  ) async throws -> Data

  /// Fetches commits between two SHAs.
  public var fetchCommitMessages:
    (
      _ owner: String,
      _ repo: String,
      _ base: Repo.Commit.SHA,
      _ head: Repo.Commit.SHA,
      _ token: GitHubAccessToken
    ) async throws -> CompareCommitsResponse

  public struct AuthTokenResponse: Codable {
    public var accessToken: GitHubAccessToken
    public init(_ accessToken: GitHubAccessToken) {
      self.accessToken = accessToken
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
      fetchBranch: { owner, repo, branch, token in
        try await jsonDataTask(
          with: fetchRepoBranch(owner: owner, repo: repo, branch: branch, token: token)
        )
      },
      fetchEmails: {
        try await jsonDataTask(with: fetchGitHubEmails(token: $0), decoder: gitHubJsonDecoder)
      },
      fetchUser: {
        try await jsonDataTask(with: fetchGitHubUser(with: $0), decoder: gitHubJsonDecoder)
      },
      fetchUserByUserID: { userID, accessToken in
        try await jsonDataTask(
          with: fetchGitHubUser(id: userID, with: accessToken),
          decoder: gitHubJsonDecoder
        )
      },
      fetchZipball: { owner, repo, ref, token in
        let (data, _) = try await dataTask(
          with: fetchGitHubZipball(owner: owner, repo: repo, ref: ref, token: token)
        )
        return Data(buffer: data)
      },
      fetchCommitMessages: { owner, repo, base, head, token in
        try await jsonDataTask(
          with: fetchGitHubCompareCommits(
            owner: owner,
            repo: repo,
            base: base,
            head: head,
            token: token
          ),
          decoder: gitHubJsonDecoder
        )
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

func fetchRepoBranch(
  owner: String,
  repo: String,
  branch: String,
  token: GitHubAccessToken
) -> HTTPClientRequest {
  apiDataTask("repos/\(owner)/\(repo)/branches/\(branch)", token: token)
}

func fetchGitHubZipball(
  owner: String,
  repo: String,
  ref: Repo.Commit.SHA,
  token: GitHubAccessToken
) -> HTTPClientRequest {
  apiDataTask("repos/\(owner)/\(repo)/zipball/\(ref)", token: token)
}

func fetchGitHubCompareCommits(
  owner: String,
  repo: String,
  base: Repo.Commit.SHA,
  head: Repo.Commit.SHA,
  token: GitHubAccessToken
) -> DecodableHTTPClientRequest<CompareCommitsResponse> {
  apiDataTask("repos/\(owner)/\(repo)/compare/\(base)...\(head)", token: token)
}

public struct CompareCommitsResponse: Codable {
  public var commits: [Commit]

  public struct Commit: Codable {
    public var commit: Detail

    public struct Detail: Codable {
      public var message: String
    }
  }
}

private func apiDataTask<A>(
  _ path: String,
  token: GitHubAccessToken
) -> DecodableHTTPClientRequest<A> {
  DecodableHTTPClientRequest(rawValue: apiDataTask(path, token: token))
}

private func apiDataTask(
  _ path: String,
  token: GitHubAccessToken
) -> HTTPClientRequest {
  var request = HTTPClientRequest(url: "https://api.github.com/\(path)")
  request.headers.add(name: "accept", value: "application/vnd.github.v3+json")
  request.headers.add(name: "authorization", value: "token \(token.rawValue)")
  return request
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
