import Either
import Foundation
import Logger
import Optics
import PointFreePrelude
import Prelude

public struct Client {
  /// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
  public var fetchAuthToken: (String) -> EitherIO<Error, Either<OAuthError, AccessToken>>

  /// Fetches a GitHub user's emails.
  public var fetchEmails: (AccessToken) -> EitherIO<Error, [User.Email]>

  /// Fetches a GitHub user from an access token.
  public var fetchUser: (AccessToken) -> EitherIO<Error, User>

  public init(
    fetchAuthToken: @escaping (String) -> EitherIO<Error, Either<OAuthError, AccessToken>>,
    fetchEmails: @escaping (AccessToken) -> EitherIO<Error, [User.Email]>,
    fetchUser: @escaping (AccessToken) -> EitherIO<Error, User>
    ) {
    self.fetchAuthToken = fetchAuthToken
    self.fetchEmails = fetchEmails
    self.fetchUser = fetchUser
  }
}

extension Client {
  public init(clientId: String, clientSecret: String, logger: Logger?) {
    self.init(
      fetchAuthToken: fetchGitHubAuthToken(clientId: clientId, clientSecret: clientSecret) >>> runGitHub(logger),
      fetchEmails: fetchGitHubEmails >>> runGitHub(logger),
      fetchUser: fetchGitHubUser >>> runGitHub(logger)
    )
  }
}

func fetchGitHubAuthToken(
  clientId: String, clientSecret: String
  )
  -> (String)
  -> DecodableRequest<Either<OAuthError, AccessToken>> {

    return { code in
      var request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
      request.httpMethod = "POST"
      request.httpBody = try? gitHubJsonEncoder.encode(
        [
          "client_id": clientId,
          "client_secret": clientSecret,
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

func fetchGitHubEmails(token: AccessToken) -> DecodableRequest<[User.Email]> {
  return apiDataTask("user/emails", token: token)
}

internal func fetchGitHubUser(with token: AccessToken) -> DecodableRequest<User> {
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
