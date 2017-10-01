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
func fetchAuthToken(forCode code: String) -> EitherIO<Prelude.Unit, GitHubAccessToken> {

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

  return .init(
    run: .init { callback in
      URLSession(configuration: .default)
        .dataTask(with: request) { data, response, error in
          callback(
            data.flatMap { try? JSONDecoder().decode(GitHubAccessToken.self, from: $0) }
              .map(Either.right)
              ?? Either.left(unit)
          )
        }
        .resume()
    }
  )
}

func mockFetchAuthToken(
  result: Either<Prelude.Unit, GitHubAccessToken>
  )
  -> (String)
  -> EitherIO<Prelude.Unit, GitHubAccessToken> {
    return { code in
      return .init(
        run: .init { callback in
          callback(result)
        }
      )
    }
}

/// Fetches a GitHub user from an access token.
func fetchGitHubUser(accessToken: GitHubAccessToken) -> EitherIO<Prelude.Unit, GitHubUser> {

  let request = URLRequest(url: URL(string: "https://api.github.com/user")!)
    |> \.allHTTPHeaderFields .~ [
      "Authorization": "token \(accessToken.accessToken)",
      "Accept": "application/vnd.github.v3+json"
  ]

  return .init(
    run: .init { callback in
      URLSession(configuration: .default)
        .dataTask(with: request) { data, response, error in
          callback(
            data.flatMap { try? JSONDecoder().decode(GitHubUser.self, from: $0) }
              .map(Either.right)
              ?? Either.left(unit)
          )
        }
        .resume()
    }
  )
}

func mockFetchGithubUser(
  result: Either<Prelude.Unit, GitHubUser>
  )
  -> (GitHubAccessToken)
  -> EitherIO<Prelude.Unit, GitHubUser> {
    return { code in
      return .init(
        run: .init { callback in
          callback(result)
        }
      )
    }
}
