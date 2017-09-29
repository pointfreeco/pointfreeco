import Either
import Foundation
import Optics
import Prelude

struct GitHubAccessToken: Codable {
  let accessToken: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}

struct GitHubUser: Codable {
  let email: String
  let id: Int
  let name: String
}

struct GitHubUserEnvelope: Codable {
  let accessToken: GitHubAccessToken
  let gitHubUser: GitHubUser
}

func authToken(forCode code: String) -> EitherIO<Prelude.Unit, GitHubAccessToken> {

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

func mockAuthToken(
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

func githubUser(accessToken: GitHubAccessToken) -> EitherIO<Prelude.Unit, GitHubUser> {

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

func githubUser(
  result: Either<Prelude.Unit, GitHubUser>
  )
  -> (String)
  -> EitherIO<Prelude.Unit, GitHubUser> {
    return { code in
      return .init(
        run: .init { callback in
          callback(result)
        }
      )
    }
}
