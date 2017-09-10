import ApplicativeRouter
import Foundation
import Html
import HttpPipeline
import Optics
import Prelude
import Styleguide

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
  requireHttps
    <<< redirectUnrelatedDomains
    <<< route(router: PointFree.router)
    <| render(conn:)

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

private func render(conn: Conn<StatusLineOpen, Route>) -> Conn<ResponseEnded, Data?> {
  let io: IO<Conn<ResponseEnded, Data?>>

  switch conn.data {
  case let .home(signedUpSuccessfully):
    io = conn.map(const(signedUpSuccessfully)) |> homeResponse
  case let .launchSignup(email):
    io = conn.map(const(email)) |> signupResponse
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

private let hosts = [
  "www.pointfree.co",
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
        if url.host.map(hosts.contains) != .some(true) {
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            |> map(\.host .~ "www.pointfree.co")
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
        }
        ?? middleware(conn)
    }
}

private let httpAllowedHosts = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

// TODO: move to HttpPipeline
private func requireHttps<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { conn in
      conn.request.url
        .filterOptional { (url: URL) -> Bool in
          url.scheme == .some("http")
            && url.host.map(httpAllowedHosts.contains) != .some(true)
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
