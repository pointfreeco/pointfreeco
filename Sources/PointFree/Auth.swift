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

let loginResponse: (Conn<StatusLineOpen, String?>) -> IO<Conn<ResponseEnded, Data?>> =
  { $0 |> redirect(to: githubAuthorizationUrl(withRedirect: $0.data)) }

let logoutResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  redirect(
    to: link(to: .secretHome),
    headersMiddleware: writeHeader(.clearCookie(key: "github_session"))
    )

private let secretHomeView = View<Either<Prelude.Unit, GitHubUserEnvelope>> { data in
  [
    h1(["welcome home"]),

    p(
      [
        a([href(link(to: .subscribe))], ["Subscribe"])
      ]
    ),

    p([
      text(
        data.right.map { "You are logged in as \($0.gitHubUser.name)" }
          ?? "You are not logged in"
      )
      ]),

    p([
       data.isRight
        ? a([href(link(to: .logout))], ["Log out"])
        : a([href(link(to: .login(redirect: link(to: .secretHome))))], ["Log in"])
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
      .flatMap { pure(createTuple) <*> $0.first <*> $0.last }
    return .init(uniqueKeysWithValues: pairs)
  }
}

// todo: move to prelude
private func createTuple<A, B>(_ a: A) -> (B) -> (A, B) {
  return { b in (a, b) }
}

public func readGitHubSessionCookieMiddleware(
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
private func authTokenMiddleware(
  _ conn: Conn<StatusLineOpen, (code: String, redirect: String?)>
  )
  -> IO<Conn<ResponseEnded, Data?>> {

    return AppEnvironment.current.fetchAuthToken(conn.data.code)
      .flatMap { token in
        AppEnvironment.current.fetchGitHubUser(token)
          .map { user in GitHubUserEnvelope(accessToken: token, gitHubUser: user) }
      }
      .run
      .flatMap { githubUserEnvelope in
        conn.map(const(githubUserEnvelope))
          |> redirect(
            to: conn.data.redirect ?? link(to: .secretHome),
            headersMiddleware: writeGitHubSessionCookieMiddleware
        )
    }
}

private func githubAuthorizationUrl(withRedirect redirect: String?) -> String {
  var params: [String: String] = [
    "scope": "user:email",
    "client_id": EnvVars.GitHub.clientId
  ]

  params["redirect_uri"] = link(to: .githubCallback(code: "", redirect: redirect))

  return "https://github.com/login/oauth/authorize?\(urlFormEncode(value: params))"
}
