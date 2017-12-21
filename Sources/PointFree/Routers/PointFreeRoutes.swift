import ApplicativeRouter
import Foundation
import Either
import Optics
import Prelude
import UrlFormEncoding

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
  case pricing(String?, Int?)
  case secretHome
  case subscribe(SubscribeData?)
  case team(Team)
  case terms

  public enum Team: DerivePartialIsos {
    case remove(Database.User.Id)
    case show
  }

  public enum Invite: DerivePartialIsos {
    case accept(Database.TeamInvite.Id)
    case resend(Database.TeamInvite.Id)
    case revoke(Database.TeamInvite.Id)
    case send(EmailAddress?)
    case show(Database.TeamInvite.Id)
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
    // TODO: double raw representable is needed cause we have to go String -> UUID -> Tagged. Might need
    //       a tagged combinator?
    <¢> post %> lit("invites") %> pathParam((._rawRepresentable) >>> (._rawRepresentable)) <% lit("accept") <% end,

  Route.iso.invite <<< Route.Invite.iso.resend
    <¢> post %> lit("invites") %> pathParam((._rawRepresentable) >>> (._rawRepresentable)) <% lit("resend") <% end,

  Route.iso.invite <<< Route.Invite.iso.revoke
    <¢> post %> lit("invites") %> pathParam((._rawRepresentable) >>> (._rawRepresentable)) <% lit("revoke") <% end,

  Route.iso.invite <<< Route.Invite.iso.send
    // TODO: this weird Optional.iso.some is cause `formField` takes a partial iso `String -> A` instead of
    //       `(String?) -> A` like it is for `queryParam`.
    <¢> post %> lit("invites") %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

  Route.iso.invite <<< Route.Invite.iso.show
    <¢> get %> lit("invites") %> pathParam((._rawRepresentable) >>> (._rawRepresentable)) <% end,

  Route.iso.launchSignup
    <¢> post %> formField("email", .rawRepresentable) <% lit("launch-signup") <% end,

  Route.iso.login
    <¢> get %> lit("login") %> queryParam("redirect", opt(.string)) <% end,

  Route.iso.logout
    <¢> get %> lit("logout") <% end,

  Route.iso.pricing
    <¢> get %> lit("pricing") %> queryParam("plan", opt(.string)) <%> queryParam("quantity", opt(.int)) <% end,

  Route.iso.secretHome
    <¢> get %> lit("home") <% end,

  Route.iso.subscribe
    <¢> post %> lit("subscribe") %> formBody(SubscribeData?.self, decoder: formDecoder) <% end,

  Route.iso.team <<< Route.Team.iso.remove
    <¢> post %> lit("account") %> lit("team") %> lit("members")
    %> pathParam((._rawRepresentable) >>> (._rawRepresentable))
    <% lit("remove")
    <% end,

  Route.iso.team <<< Route.Team.iso.show
    <¢> get %> lit("account") %> lit("team") <% end,

  Route.iso.terms
    <¢> get %> lit("terms") <% end,

]

private let formDecoder = UrlFormDecoder()
  |> \.parsingStrategy .~ .bracketsWithIndices

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
