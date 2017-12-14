import ApplicativeRouterHttpPipelineSupport
import Foundation
import HttpPipeline
import Prelude
import Styleguide
import Tuple

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requestLogger { AppEnvironment.current.logger.info($0) }
    <<< requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< basicAuth(
      user: AppEnvironment.current.envVars.basicAuth.username,
      password: AppEnvironment.current.envVars.basicAuth.password,
      realm: "Point-Free",
      protect: isProtected
    )
    <| (
      readSessionCookieMiddleware
        >-> render(conn:)
)

private func render(conn: Conn<StatusLineOpen, Tuple2<Route, Database.User?>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (route, user) = lower <| conn.data
    switch route {
    case .about:
      return conn.map(const(unit))
        |> aboutResponse

    case let .episode(param):
      return conn.map(const(param))
        |> episodeResponse

    case let .gitHubCallback(code, redirect):
      return conn.map(const((code, redirect)))
        |> gitHubCallbackResponse

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
      return conn.map(const(value ?? .monthlyTeam))
        |> pricingResponse

    case .secretHome:
      return conn.map(const(unit))
        |> secretHomeResponse

    case let .subscribe(data):
      return conn.map(const(data))
        |> subscribeResponse

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
  case .about,
       .episode,
       .gitHubCallback,
       .login,
       .logout,
       .pricing,
       .secretHome,
       .subscribe,
       .terms:

    return true

  case .home,
       .launchSignup:
    
    return false
  }
}
