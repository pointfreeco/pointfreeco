import ApplicativeRouter
import Foundation
import Html
import HttpPipeline
import Prelude
import Styleguide

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
  route(router: PointFree.router)
    <| (render(conn:) >>> perform)

public enum Route {
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
}

func link(to route: Route) -> String {
  switch route {
  case let .home(.some(signedUpSuccessfully)):
    return "/?success=\(signedUpSuccessfully)"
  case .home:
    return "/"
  case .launchSignup:
    return "/launch-signup"
  }
}

private let router =
  Route.home <¢> (.get *> opt(param("success", map(toBool)))) <*| end
    <|> Route.launchSignup <¢> (.post *> .formField("email")) <* lit("launch-signup") <*| end

private func render(conn: Conn<StatusLineOpen, Route>) -> IO<Conn<ResponseEnded, Data?>> {
  switch conn.data {
  case let .home(signedUpSuccessfully):
    return conn.map(const(signedUpSuccessfully)) |> homeResponse
  case let .launchSignup(email):
    return conn.map(const(email)) |> signupResponse
  }
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

private func toBool(string: String) -> Bool {
  return string == "true" || string == "1"
}
