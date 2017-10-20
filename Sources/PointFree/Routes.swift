import ApplicativeRouter
import ApplicativeRouterHttpPipelineSupport
import Foundation
import Html
import HttpPipeline
import Optics
import Prelude
import Styleguide

public enum Route {
  case githubCallback(code: String, redirect: String?)
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
  case login(redirect: String?)
  case logout
  case secretHome
  case subscribe
}

let router: Router<Route> = [
  Route.iso.githubCallback
    <¢> get %> lit("github-auth") %> queryParam("code", .string) <%> queryParam("redirect", opt(.string)) <% end,

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

public func path(to route: Route) -> String {
  return router.absoluteString(for: route)
}

public func url(to route: Route) -> String {
  return router.url(for: route, base: AppEnvironment.current.baseUrl)?.absoluteString ?? ""
}

fileprivate extension Route {
  enum iso {
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
