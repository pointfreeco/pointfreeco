import Either
import Foundation
import Logger
import Optics
import PointFreePrelude
import Prelude
import Tagged

public struct Client {
  /// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
  public var fetchAuthToken: (String) -> EitherIO<Error, Either<OAuthError, AccessToken>>

  /// Fetches a GitHub user's emails.
  public var fetchEmails: (AccessToken) -> EitherIO<Error, [GitHubUser.Email]>

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (AccessToken) -> EitherIO<Error, GitHubUser>

  public init(
    fetchAuthToken: @escaping (String) -> EitherIO<Error, Either<OAuthError, AccessToken>>,
    fetchEmails: @escaping (AccessToken) -> EitherIO<Error, [GitHubUser.Email]>,
    fetchUser: @escaping (AccessToken) -> EitherIO<Error, GitHubUser>
    ) {
    self.fetchAuthToken = fetchAuthToken
    self.fetchEmails = fetchEmails
    self.fetchUser = fetchUser
  }
}

extension Client {
  public typealias Id = Tagged<(Client, id: ()), String>
  public typealias Secret = Tagged<(Client, secret: ()), String>

  public init(clientId: Id, clientSecret: Secret, logger: Logger?) {
    self.init(
      fetchAuthToken: fetchGitHubAuthToken(clientId: clientId, clientSecret: clientSecret) >>> runGitHub(logger),
      fetchEmails: fetchGitHubEmails >>> runGitHub(logger),
      fetchUser: fetchGitHubUser >>> runGitHub(logger)
    )
  }
}

func fetchGitHubAuthToken(
  clientId: Client.Id, clientSecret: Client.Secret
  )
  -> (String)
  -> DecodableRequest<Either<OAuthError, AccessToken>> {

    return { code in
      var request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
      request.httpMethod = "POST"
      request.httpBody = try? gitHubJsonEncoder.encode(
        [
          "client_id": clientId.rawValue,
          "client_secret": clientSecret.rawValue,
          "code": code,
          "accept": "json"
        ])
      request.allHTTPHeaderFields = [
        "Content-Type": "application/json",
        "Accept": "application/json"
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
  return DecodableRequest(
    rawValue: URLRequest(url: URL(string: "https://api.github.com/" + path)!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "token \(token.accessToken)",
        "Accept": "application/vnd.github.v3+json"
    ]
  )
}

private func runGitHub<A>(_ logger: Logger?) -> (DecodableRequest<A>) -> EitherIO<Error, A> {
  return { gitHubRequest in
    jsonDataTask(with: gitHubRequest.rawValue, decoder: gitHubJsonDecoder, logger: logger)
  }
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
