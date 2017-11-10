import ApplicativeRouterHttpPipelineSupport
import Foundation
import HttpPipeline
import Prelude

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data> =
  requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< basicAuth(
      user: EnvVars.BasicAuth.username,
      password: EnvVars.BasicAuth.password,
      realm: "Point-Free",
      protect: isProtected
    )
    <| render(conn:)

private func render(conn: Conn<StatusLineOpen, Never, Route>) -> IO<Conn<ResponseEnded, Never, Data>> {

  switch conn.data.right! {
  case let .githubCallback(code, redirect):
    return conn.map(const((code, redirect)))
      |> githubCallbackResponse

  case let .home(signedUpSuccessfully):
    return conn.map(const(signedUpSuccessfully))
      |> homeResponse

  case let .launchSignup(email):
    return conn.map(const(email))
      |> signupResponse

  case let .login(redirect):
    return conn.map(const(redirect))
      |> loginResponse

  case .logout:
    return conn.map(const(unit))
      |> logoutResponse

  case .secretHome:
    return conn.map(const(unit))
      |> secretHomeResponse
  }
}

private let canonicalHost = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalHost,
  EnvVars.baseUrl?.host ?? canonicalHost,
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private let allowedInsecureHosts: [String] = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private func isProtected(route: Route) -> Bool {
  switch route {
  case .githubCallback, .login, .logout, .secretHome:
    return true
  case .home, .launchSignup:
    return false
  }
}
