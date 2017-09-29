import ApplicativeRouter
import Foundation
import Html
import HttpPipeline
import Optics
import Prelude
import Styleguide

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
  requireHerokuHttps
    <<< redirectUnrelatedDomains
    <<< route(router: PointFree.router)
    <| render(conn:)

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

private func render(conn: Conn<StatusLineOpen, Route>) -> Conn<ResponseEnded, Data?> {
  let io: IO<Conn<ResponseEnded, Data?>>

  switch conn.data {
  case let .githhubCallback(code):
    io = conn.map(const(code)) |> githubCallbackResponse
  case let .home(signedUpSuccessfully):
    io = conn.map(const(signedUpSuccessfully)) |> homeResponse
  case let .launchSignup(email):
    io = conn.map(const(email)) |> signupResponse
  case .login:
    io = conn.map(const(unit)) |> loginResponse
  case .logout:
    io = conn.map(const(unit)) |> logoutResponse
  case .secretHome:
    io = conn.map(const(unit)) |> secretHomeResponse
  }

  return io.perform()
}

// TODO: move to support file for HttpPipeline+ApplicativeParser
private func route<I, A, Route>(
  router: Parser<I, Route>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, Route, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { middleware in
      return { conn in

        router.match(conn.request)
          .map(const >>> conn.map >>> middleware)
          ?? (conn |> notFound(respond(text: "don't know that url")))
      }
    }
}

private let canonicalUrl = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalUrl,
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

// TODO: move to HttpPipeline
private func redirectUnrelatedDomains<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { conn in
      return conn.request.url.flatMap { url in
        if !allowedHosts.contains(url.host ?? "") {
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            |> map(\.host .~ canonicalUrl)
          return components?.url.map {
            conn
              |> writeStatus(.movedPermanently)
              |> writeHeader(.location($0.absoluteString))
              |> map(const(nil))
              |> closeHeaders
              |> end
          }
        } else {
          return nil
        }
        } ?? middleware(conn)
    }
}

private let allowedInsecureHosts: [String] = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

// TODO: move to HttpPipeline
private func requireHerokuHttps<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { conn in
      conn.request.url
        .filterOptional { (url: URL) -> Bool in
          // `url.scheme` cannot be trusted on Heroku, instead we need to look at the `X-Forwarded-Proto`
          // header to determine if we are on https or not.
          conn.request.allHTTPHeaderFields?["X-Forwarded-Proto"] != .some("https")
            && !allowedInsecureHosts.contains(url.host ?? "")
        }
        .flatMap(makeHttps)
        .map {
          conn
            |> writeStatus(.movedPermanently)
            |> writeHeader(.location($0.absoluteString))
            |> map(const(nil))
            |> closeHeaders
            |> end
        }
        ?? middleware(conn)
    }
}

// TODO: move to httppipeline?
private func makeHttps(url: URL) -> URL? {
  return URLComponents(url: url, resolvingAgainstBaseURL: false)
    |> map(\.scheme .~ "https")
    |> flatMap { $0.url }
}

// TODO: move to prelude
extension Optional {
  fileprivate func filterOptional(_ p: (Wrapped) -> Bool) -> Optional {
    return self.flatMap { p($0) ? $0 : nil }
  }
}

private func toBool(string: String) -> Bool {
  return string == "true" || string == "1"
}
