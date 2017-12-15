import ApplicativeRouter
import Foundation
import Either
import Prelude

public protocol DerivePartialIsos {}

public enum Route: DerivePartialIsos {
  case about
  case account
  case episode(Either<String, Int>)
  case gitHubCallback(code: String?, redirect: String?)
  case home(signedUpSuccessfully: Bool?)
  case invite(Invite)
  case launchSignup(EmailAddress)
  case login(redirect: String?)
  case logout
  case pricing(Stripe.Plan.Id?)
  case secretHome
  case subscribe(SubscribeData)
  case team
  case terms

  public enum Invite: DerivePartialIsos {
    case accept(UUID)
    case send(EmailAddress)
    case show(UUID)
  }
}

extension UUID: RawRepresentable {
  public var rawValue: String {
    return self.uuidString
  }

  public init?(rawValue: String) {
    guard let uuid = UUID(uuidString: rawValue) else { return nil }
    self = uuid
  }
}

private let routers: [Router<Route>] = [

  Route.iso.about
    <¢> get %> lit("about") <% end,

  Route.iso.account
    <¢> get %> lit("account") <% end,

  Route.iso.episode
    <¢> get %> lit("episodes") %> pathParam(.intOrString) <% end,

  Route.iso.gitHubCallback
    <¢> get %> lit("github-auth")
    %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
    <% end,

  Route.iso.home
    <¢> get %> queryParam("success", opt(.bool)) <% end,

  Route.iso.invite <<< Route.Invite.iso.accept
    <¢> get %> lit("invites") %> pathParam(.rawRepresentable) <% lit("accept") <% end,

  Route.iso.invite <<< Route.Invite.iso.send
    <¢> post %> lit("invites") %> formField("email", .rawRepresentable) <% end,

  Route.iso.invite <<< Route.Invite.iso.show
    <¢> get %> lit("invites") %> pathParam(.rawRepresentable) <% end,

  Route.iso.launchSignup
    <¢> post %> formField("email", .rawRepresentable) <% lit("launch-signup") <% end,

  Route.iso.login
    <¢> get %> lit("login") %> queryParam("redirect", opt(.string)) <% end,

  Route.iso.logout
    <¢> get %> lit("logout") <% end,

  Route.iso.pricing
    <¢> get %> lit("pricing") %> queryParam("plan", opt(.iso(.rawRepresentable, default: .monthly))) <% end,

  Route.iso.secretHome
    <¢> get %> lit("home") <% end,

  Route.iso.subscribe
    <¢> post %> lit("subscribe") %> formDataBody(SubscribeData.self) <% end,

  Route.iso.team
    <¢> get %> lit("account") %> lit("team") <% end,

  Route.iso.terms
    <¢> get %> lit("terms") <% end,

]

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
