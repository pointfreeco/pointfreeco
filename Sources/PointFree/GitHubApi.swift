import Either
import Foundation
import Optics
import Prelude

public struct GitHubAccessToken: Codable {
  let accessToken: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}

public struct GitHubUser: Codable {
  let email: String
  let id: Int
  let name: String
}

public struct GitHubUserEnvelope: Codable {
  let accessToken: GitHubAccessToken
  let gitHubUser: GitHubUser
}

/// Fetches an access token from GitHub from a `code` that was obtained from the callback redirect.
func fetchAuthToken(forCode code: String) -> EitherIO<Error, GitHubAccessToken> {

  let request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
    |> \.httpMethod .~ "POST"
    |> \.httpBody .~ (try? JSONEncoder().encode(
      [
        "client_id": EnvVars.GitHub.clientId,
        "client_secret": EnvVars.GitHub.clientSecret,
        "code": code,
        "accept": "json"
      ]))
    |> \.allHTTPHeaderFields .~ [
      "Content-Type": "application/json",
      "Accept": "application/json"
  ]

  return (jsonDataTask(session) <| decoder) <| request
}

/// Fetches a GitHub user from an access token.
func fetchGitHubUser(accessToken: GitHubAccessToken) -> EitherIO<Error, GitHubUser> {

  let request = URLRequest(url: URL(string: "https://api.github.com/user")!)
    |> \.allHTTPHeaderFields .~ [
      "Authorization": "token \(accessToken.accessToken)",
      "Accept": "application/vnd.github.v3+json"
  ]

  return (jsonDataTask(session) <| decoder) <| request
}

// TODO: Move to Prelude
public extension Either where L == Error {
  public static func wrap(_ f: @escaping () throws -> R) -> Either {
    do {
      return .right(try f())
    } catch let error {
      return .left(error)
    }
  }
}

// TODO: Move to PreludeFoundation?
public func jsonDataTask<A>(_ session: URLSession)
  -> (JSONDecoder)
  -> (URLRequest)
  -> EitherIO<Error, A>
  where A: Decodable {

    return { decoder in
      { request in
        .init(
          run: .init { callback in
            session
              .dataTask(with: request) { data, response, error in
                callback(
                  data
                    .map { data in Either.wrap { try decoder.decode(A.self, from: data) } }
                    ?? .left(error!)
                )
              }
              .resume()
          }
        )
      }
    }
}

private let session = URLSession(configuration: .default)

private let decoder = JSONDecoder()
