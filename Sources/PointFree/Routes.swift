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
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHosts)
    <<< route(router: router)
    <<< protectRoutes
    <| render(conn:)
    >>> perform

public enum Route {
  case githubCallback(code: String, redirect: String?)
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
  case login(redirect: String?)
  case logout
  case secretHome
  case subscribe
}

func link(to route: Route, absolute: Bool = false) -> String {

  func path(to: Route) -> String {
    switch route {
    case let .githubCallback(_, redirect):
      let param = redirect
        .flatMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed) }
        .map { "redirect=\($0)" }
        ?? ""
      return "/github-auth?\(param)"
    case let .home(.some(signedUpSuccessfully)):
      return "/?success=\(signedUpSuccessfully)"
    case .home:
      return "/"
    case .launchSignup:
      return "/launch-signup"
    case let .login(redirect):
      let param = redirect
        .flatMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed) }
        .map { "?redirect=\($0)" }
        ?? ""
      return "/login\(param)"
    case .logout:
      return "/logout"
    case .secretHome:
      return "/home"
    case .subscribe:
      return "/subscribe"
    }
  }

  // TODO: figure out absolute base url
  return absolute
    ? "http://localhost:8080\(path(to: route))"
    : path(to: route)
}

private let tmp =
  curry(Route.githubCallback) <¢> (.get <* lit("github-auth") *> param("code")) <*> opt(param("redirect")) <*| end
    <|> Route.home <¢> (.get *> opt(param("success", map(toBool)))) <*| end
    <|> Route.launchSignup <¢> (.post *> .formField("email")) <* lit("launch-signup") <*| end
    <|> Route.login <¢> (.get <* lit("login") *> opt(param("redirect"))) <*| end

private let router =
  tmp
    <|> Route.logout <¢ (.get <* lit("logout")) <*| end
    <|> Route.secretHome <¢ (.get <* lit("home")) <*| end
    <|> Route.subscribe <¢ (.get <* lit("subscribe")) <*| end

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

private let canonicalHosts = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalHosts,
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
        |> writeHeader(.wwwAuthenticate(.basic(realm: "Point-Free")))
        |> respond(text: "Please authenticate.")
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
