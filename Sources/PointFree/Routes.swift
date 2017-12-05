import ApplicativeRouter
import Either
import Prelude

public protocol DerivePartialIsos {}

public enum Route: DerivePartialIsos {
  case about
  case episode(Either<String, Int>)
  case episodes(tag: Tag?)
  case gitHubCallback(code: String?, redirect: String?)
  case home(signedUpSuccessfully: Bool?)
  case launchSignup(email: String)
  case login(redirect: String?)
  case logout
  case pricing(Stripe.Plan.Id?)
  case secretHome
  case subscribe(Stripe.Plan.Id, token: String)
  case terms
}

private let routers: [Router<Route>] = [

  Route.iso.about
    <¢> get %> lit("about") <% end,

  Route.iso.episode
    <¢> get %> lit("episodes") %> pathParam(.intOrString) <% end,

  Route.iso.episodes
    <¢> get %> lit("episodes") %> queryParam("tag", opt(.tag)) <% end,

  Route.iso.gitHubCallback
    <¢> get %> lit("github-auth")
    %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
    <% end,

  Route.iso.home
    <¢> get %> queryParam("success", opt(.bool)) <% end,

  Route.iso.launchSignup
    <¢> post %> formField("email") <% lit("launch-signup") <% end,

  Route.iso.login
    <¢> get %> lit("login") %> queryParam("redirect", opt(.string)) <% end,

  Route.iso.logout
    <¢> get %> lit("logout") <% end,

  Route.iso.pricing
    <¢> get %> lit("pricing") %> queryParam("plan", opt(.iso(.rawRepresentable, default: .monthly))) <% end,

  Route.iso.secretHome
    <¢> get %> lit("home") <% end,

  Route.iso.subscribe
    <¢> post %> lit("subscribe") %> formField("plan", .rawRepresentable) <%> formField("token") <% end,

  Route.iso.terms
    <¢> get %> lit("terms") <% end,

]

// TODO: Move to swift-web
extension PartialIso {
  public static func iso(_ iso: PartialIso, default: B) -> PartialIso {
    return .init(
      apply: { iso.apply($0) ?? `default` },
      unapply: iso.unapply
    )
  }
}

extension PartialIso where A == String, B: RawRepresentable, B.RawValue == String {
  public static var rawRepresentable: PartialIso {
    return .init(
      apply: B.init(rawValue:),
      unapply: ^\.rawValue
    )
  }
}

public let router = routers.reduce(.empty, <|>)

public func path(to route: Route) -> String {
  return router.absoluteString(for: route)
}

public func url(to route: Route) -> String {
  return router.url(for: route, base: AppEnvironment.current.envVars.baseUrl)?.absoluteString ?? ""
}

extension PartialIso where A == String, B == Tag {
  public static var tag: PartialIso<String, Tag> {
    return PartialIso<String, Tag>(
      apply: Tag.init(slug:),
      unapply: ^\.name
    )
  }
}
