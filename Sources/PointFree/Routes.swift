import ApplicativeRouter
import Either
import Prelude

public enum Route {
  case episode(Either<String, Int>)
  case episodes
  case githubCallback(code: String, redirect: String?)
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
  case login(redirect: String?)
  case logout
  case secretHome
}

public let router: Router<Route> = [

  Route.iso.episode
    <¢> get %> lit("episodes") %> pathParam(.intOrString) <% end,

  Route.iso.episodes
    <¢> get %> lit("episodes") <% end,

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
  ]
  .reduce(.empty, <|>)

extension Route {
  public enum iso {
    static let episode = parenthesize <| PartialIso(
      apply: Route.episode,
      unapply: {
        guard case let .episode(result) = $0 else { return nil }
        return result
    })

    static let episodes = parenthesize <| PartialIso<Prelude.Unit, Route>(
      apply: const(.some(.episodes)),
      unapply: {
        guard case .episodes = $0 else { return nil }
        return unit
    })


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
  }
}

public func path(to route: Route) -> String {
  return router.absoluteString(for: route)
}

public func url(to route: Route) -> String {
  return router.url(for: route, base: AppEnvironment.current.envVars.baseUrl)?.absoluteString ?? ""
}
