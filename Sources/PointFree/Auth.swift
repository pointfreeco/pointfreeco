import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude

let secretHomeResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  writeStatus(.ok)
    >-> readGitHubSessionCookieMiddleware
    >-> respond(secretHomeView)


let githubCallbackResponse =
  authTokenMiddleware
    >-> redirect(to: link(to: .secretHome), headersMiddleware: writeGitHubSessionCookieMiddleware)

let loginResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  redirect(to: githubAuthorizationUrl)

let logoutResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  redirect(
    to: link(to: .secretHome),
    headersMiddleware: writeHeader(.clearCookie(key: "github_session"))
    )

private let secretHomeView = View<Either<Prelude.Unit, GitHubUserEnvelope>> { data in
  [
    p(["welcome home"]),

    p([
      text(
        data.right.map { "You are logged in as \($0.gitHubUser.name)" }
          ?? "You are not logged in"
      )
      ]),

    p([
       data.isRight
        ? a([href(link(to: .logout))], ["Log out"])
        : a([href(link(to: .login))], ["Log in"])
      ])
    ]
}

// todo: move to swift-web
extension URLRequest {
  public var cookies: [String: String] {
    let pairs = (self.allHTTPHeaderFields?["Cookie"] ?? "")
      .components(separatedBy: "; ")
      .map {
        $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
          .map(String.init)
      }
      .flatMap { pure(tuple) <*> $0.first <*> $0.last }
    return .init(uniqueKeysWithValues: pairs)
  }
}

private func readGitHubSessionCookieMiddleware(
  _ conn: Conn<HeadersOpen, Prelude.Unit>
  )
  -> IO<Conn<HeadersOpen, Either<Prelude.Unit, GitHubUserEnvelope>>> {

    return pure <| conn.map(
      const(
        conn.request.cookies["github_session"]
          .flatMap { ResponseHeader.verifiedValue(signedCookieValue: $0, secret: EnvVars.appSecret) }
          .map(Either.right)
          ?? Either.left(unit)
      )
    )
}

private func writeGitHubSessionCookieMiddleware(
  _ conn: Conn<HeadersOpen, Either<Prelude.Unit, GitHubUserEnvelope>>
  )
  -> IO<Conn<HeadersOpen, Either<Prelude.Unit, GitHubUserEnvelope>>> {

    switch conn.data {
    case .left:
      return conn |> pure
    case let .right(envelope):
      return conn |> writeHeaders(
        [
          ResponseHeader.setSignedCookie(
            key: "github_session",
            value: envelope,
            options: [],
            secret: EnvVars.appSecret,
            encrypt: true
          )
          ] |> catOptionals
      )
    }
}

/// Exchanges a github code for an access token and loads the user's data.
private func authTokenMiddleware<I>(
  _ conn: Conn<I, String>
  )
  -> IO<Conn<I, Either<Prelude.Unit, GitHubUserEnvelope>>> {

    return AppEnvironment.current.fetchAuthToken(conn.data)
      .flatMap { token in
        AppEnvironment.current.fetchGitHubUser(token)
          .map { user in GitHubUserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .run
      .map(conn.map <<< const)
}

private let githubAuthorizationUrl =
  "https://github.com/login/oauth/authorize?scope=user:email&client_id=\(EnvVars.GitHub.clientId)"
