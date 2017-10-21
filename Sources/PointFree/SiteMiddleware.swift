import ApplicativeRouterHttpPipelineSupport
import Foundation
import HttpPipeline
import Prelude

public let siteMiddleware =
  requestLogger
    <<< requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< basicAuth(
      user: EnvVars.BasicAuth.username,
      password: EnvVars.BasicAuth.password,
      realm: "Point-Free",
      protect: isProtected(route:)
    )
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

// TODO: Move to swift-web
private func requestLogger(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> {
    return requestLogger(logger: { print($0) })(middleware)
}

// TODO: Move to swift-web
private func requestLogger(logger: (String) -> Void)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> {

    return { middleware in
      return { conn in
        let startTime = Date().timeIntervalSince1970
        return middleware(conn).flatMap { b in
          IO {
            let endTime = Date().timeIntervalSince1970
            print("[Route] \(conn.request.httpMethod ?? "GET") \(conn.request)")
            print("[Time]  \(Int((endTime - startTime) * 1000))ms")
            return b
          }
        }
      }
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
