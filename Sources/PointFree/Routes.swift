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
  case githubCallback(code: String, redirect: String)
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
  case login(redirect: String?)
  case logout
  case secretHome
  case subscribe

  public enum iso {
    static let githubCallback = parenthesize <| PartialIso(
      apply: Route.githubCallback,
      unapply: {
        guard case let .githubCallback(result) = $0 else { return nil }
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

    static let login = parenthesize <| PartialIso(
      apply: Route.login,
      unapply: {
        guard case let .login(result) = $0 else { return nil }
        return result
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

    static let subscribe = parenthesize <| PartialIso<Prelude.Unit, Route>(
      apply: const(.some(.subscribe)),
      unapply: {
        guard case .subscribe = $0 else { return nil }
        return unit
    })
  }
}

public func path(to route: Route) -> String {
  return router.absoluteString(for: route)
}

public func url(to route: Route) -> String {
  return router.url(for: route, base: AppEnvironment.current.baseUrl)?.absoluteString ?? ""
}

private let router: Router<Route> = [
  Route.iso.githubCallback
    <¢> get %> lit("github-auth") %> queryParam("code", .string) <%> queryParam("redirect", .string) <% end,

  Route.iso.home
    <¢> get %> queryParam("success", opt(.bool)) <% end,

  Route.iso.launchSignup
    <¢> post %> formField("email") <% lit("launch-signup") <% end,

  Route.iso.login
    <¢> get %> lit("login") %> queryParam("redirect", opt(.string)) <% end,

  Route.iso.logout
    <¢> get %> lit("logout") <% end,

  Route.iso.secretHome
    <¢> get %> lit("home") <% end,

  Route.iso.subscribe
    <¢> get %> lit("subscribe") <% end,
  ]
  .reduce(.empty, <|>)

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
  case .githubCallback, .login, .logout, .secretHome, .subscribe:
    return true
  case .home, .launchSignup:
    return false
  }
}
