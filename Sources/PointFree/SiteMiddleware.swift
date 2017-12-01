import ApplicativeRouterHttpPipelineSupport
import Foundation
import HttpPipeline
import Prelude
import Styleguide

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< basicAuth(
      user: AppEnvironment.current.envVars.basicAuth.username,
      password: AppEnvironment.current.envVars.basicAuth.password,
      realm: "Point-Free",
      protect: isProtected
    )
    <| render(conn:)

private func render(conn: Conn<StatusLineOpen, Route>) -> IO<Conn<ResponseEnded, Data>> {

  switch conn.data {
  case .about:
    return conn.map(const(unit))
      |> aboutResponse

  case let .episode(param):
    return conn.map(const(param))
      |> episodeResponse

  case let .episodes(tag):
    return conn.map(const(tag))
      |> episodesResponse

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

  case let .pricing(value):
    return conn.map(const(value))
      |> pricingResponse

  case .secretHome:
    return conn.map(const(unit))
      |> secretHomeResponse

  case let .subscribe(stripeToken):
    fatalError()

  case .terms:
    return conn.map(const(unit))
      |> termsResponse
  }
}

private let canonicalHost = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalHost,
  AppEnvironment.current.envVars.baseUrl.host ?? canonicalHost,
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
  case .about, .episode, .episodes, .githubCallback, .login, .logout, .pricing, .secretHome, .subscribe, .terms:
    return true
  case .home, .launchSignup:
    return false
  }
}
