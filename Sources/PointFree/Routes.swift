import ApplicativeRouter
import ApplicativeRouterHttpPipelineSupport
import Foundation
import Html
import HttpPipeline
import Optics
import Prelude
import Styleguide

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
  requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< protectRoutes
    <| render(conn:)

public enum Route {
  case githhubCallback(code: String)
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
  case login
  case logout
  case secretHome

  public enum iso {
    static let githhubCallback = parenthesize <| PartialIso(
      apply: Route.githhubCallback,
      unapply: {
        guard case let .githhubCallback(result) = $0 else { return nil }
        return result
    })

    static let home = parenthesize <| PartialIso(
      apply: Route.home,
      unapply: {
        guard case let .home(result) = $0 else { return nil }
        return result
    })

    static let launchSignup = parenthesize <| PartialIso(
      apply: Route.launchSignup,
      unapply: {
        guard case let .launchSignup(result) = $0 else { return nil }
        return result
    })

    static let login = parenthesize <| PartialIso<Prelude.Unit, Route>(
      apply: const(.some(.login)),
      unapply: {
        guard case .login = $0 else { return nil }
        return unit
    })

    static let logout = parenthesize <| PartialIso<Prelude.Unit, Route>(
      apply: const(.some(.logout)),
      unapply: {
        guard case .logout = $0 else { return nil }
        return unit
    })

    static let secretHome = parenthesize <| PartialIso<Prelude.Unit, Route>(
      apply: const(.some(.secretHome)),
      unapply: {
        guard case .secretHome = $0 else { return nil }
        return unit
    })
  }
}

public func link(to route: Route) -> String {
  return router.url(for: route)?.absoluteString ?? ""
}

private let router: Router<Route> = [
  Route.iso.githhubCallback
    <¢> get %> lit("github-auth") %> queryParam("code") <% end,

  Route.iso.home
    <¢> get %> queryParam("success", opt(.bool)) <% end,

  Route.iso.launchSignup
    <¢> post %> formField("email") <% lit("launch-signup") <% end,

  Route.iso.login
    <¢> get %> lit("login") <% end,

  Route.iso.logout
    <¢> get %> lit("logout") <% end,

  Route.iso.secretHome
    <¢> get %> lit("home") <% end,
  ]
  .reduce(.empty, <|>)

private func render(conn: Conn<StatusLineOpen, Route>) -> IO<Conn<ResponseEnded, Data?>> {

  switch conn.data {
  case let .githhubCallback(code):
    return conn.map(const(code))
      |> githubCallbackResponse

  case let .home(signedUpSuccessfully):
    return conn.map(const(signedUpSuccessfully))
      |> homeResponse

  case let .launchSignup(email):
    return conn.map(const(email))
      |> signupResponse

  case .login:
    return conn.map(const(unit))
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
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private let allowedInsecureHosts: [String] = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private func toBool(string: String) -> Bool {
  return string == "true" || string == "1"
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

      if !isProtected(route: conn.data) || validated {
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
  case .githhubCallback, .login, .logout, .secretHome:
    return true
  case .home, .launchSignup:
    return false
  }
}
