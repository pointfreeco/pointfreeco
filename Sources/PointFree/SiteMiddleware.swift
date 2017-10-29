import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Prelude

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< basicAuth(
      user: EnvVars.BasicAuth.username,
      password: EnvVars.BasicAuth.password,
      realm: "Point-Free",
      protect: isProtected
    )
    <<< handleErrors
    <| render(conn:)

private func render(conn: Conn<StatusLineOpen, Route>)
  -> IO<Conn<ResponseEnded, Either<Error, Data>>> {

    switch conn.data {
    case let .githubCallback(code, redirect):
      return conn.map(const((code, redirect)))
        |> githubCallbackResponse

    case let .home(signedUpSuccessfully):
      return conn.map(const(signedUpSuccessfully))
        |> homeResponse
        >>> map(map(pure))

    case let .launchSignup(email):
      return conn.map(const(email))
        |> signupResponse
        >>> map(map(pure))

    case let .login(redirect):
      return conn.map(const(redirect))
        |> loginResponse
        >>> map(map(pure))

    case .logout:
      return conn.map(const(unit))
        |> logoutResponse
        >>> map(map(pure))

    case .secretHome:
      return conn.map(const(unit))
        |> secretHomeResponse
        >>> map(map(pure))
    }
}

public func handleErrors<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Either<Error, Data>>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { conn in
      middleware(conn)
        .flatMap {
          switch $0.data {
          case let .left(error):
            switch AppEnvironment.current.deployedTo {
            case .production:
              return conn
                |> writeStatus(.internalServerError)
                >-> respond(text: "An error occurred.")
            case .development, .staging:
              return conn
                |> writeStatus(.internalServerError)
                >-> respond(text: error.localizedDescription)
            }
          case let .right(data):
            return pure($0.map(const(data)))
          }
      }
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
