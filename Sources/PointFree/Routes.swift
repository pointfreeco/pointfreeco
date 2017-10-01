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
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalUrl)
    <<< route(router: PointFree.router)
    <| render(conn:)
    >>> perform

public enum Route {
  case githhubCallback(code: String)
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
  case login
  case logout
  case secretHome
}

func link(to route: Route) -> String {
  switch route {
  case let .githhubCallback(code):
    return "/github-callback?code=\(code)"
  case let .home(.some(signedUpSuccessfully)):
    return "/?success=\(signedUpSuccessfully)"
  case .home:
    return "/"
  case .launchSignup:
    return "/launch-signup"
  case .login:
    return "/login"
  case .logout:
    return "/logout"
  case .secretHome:
    return "/home"
  }
}

private let router =
  Route.githhubCallback <¢> (.get <* lit("github-auth") *> param("code")) <*| end
    <|> Route.home <¢> (.get *> opt(param("success", map(toBool)))) <*| end
    <|> Route.launchSignup <¢> (.post *> .formField("email")) <* lit("launch-signup") <*| end
    <|> Route.login <¢ (.get <* lit("login")) <*| end
    <|> Route.logout <¢ (.get <* lit("logout")) <*| end
    <|> Route.secretHome <¢ (.get <* lit("home")) <*| end

private func render(conn: Conn<StatusLineOpen, Route>) -> IO<Conn<ResponseEnded, Data?>> {

  switch conn.data {
  case let .githhubCallback(code):
    return conn.map(const(code)) |> githubCallbackResponse
  case let .home(signedUpSuccessfully):
    return conn.map(const(signedUpSuccessfully)) |> homeResponse
  case let .launchSignup(email):
    return conn.map(const(email)) |> signupResponse
  case .login:
    return conn.map(const(unit)) |> loginResponse
  case .logout:
    return conn.map(const(unit)) |> logoutResponse
  case .secretHome:
    return conn.map(const(unit)) |> secretHomeResponse
  }
}

private let canonicalUrl = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalUrl,
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
