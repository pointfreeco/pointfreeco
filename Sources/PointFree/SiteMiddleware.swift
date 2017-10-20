import ApplicativeRouterHttpPipelineSupport
import Foundation
import HttpPipeline
import Prelude

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
  requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< routeLogger
    <<< protectRoutes
    <| render(conn:)

private func render(conn: Conn<StatusLineOpen, Route>) -> IO<Conn<ResponseEnded, Data?>> {

  switch conn.data {
  case let .githubCallback(code, redirect):
    return conn.map(const((code: code, redirect: redirect)))
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

  case .subscribe:
    return conn.map(const(unit))
      |> subscribeResponse
  }
}

private let canonicalHost = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalHost,
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private let allowedInsecureHosts: [String] = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private func routeLogger<I, J, B>(
  _ middleware: @escaping Middleware<I, J, Route, B>
  )
  -> Middleware<I, J, Route, B> {

    return { conn in
      return (conn |> middleware).flatMap { b in
        IO {
          print("[Route] \(conn.request)")
          return b
        }
      }
    }
}

private let protectRoutes:
  (@escaping Middleware<StatusLineOpen, ResponseEnded, Route, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, Route, Data?>
  = { middleware in
    return { conn in
      let validated = validateBasicAuth(
        user: EnvVars.BasicAuth.username,
        password: EnvVars.BasicAuth.password,
        request: conn.request
      )

      guard isProtected(route: conn.data) && !validated else {
        return middleware(conn)
      }

      return conn
        |> writeStatus(.unauthorized)
        >-> writeHeader(.wwwAuthenticate(.basic(realm: "Point-Free")))
        >-> respond(text: "Please authenticate.")
    }
}

private func isProtected(route: Route) -> Bool {
  switch route {
  case .githubCallback, .login, .logout, .secretHome, .subscribe:
    return true
  case .home, .launchSignup:
    return false
  }
}
