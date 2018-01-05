import ApplicativeRouter
import Foundation
import Either
import Optics
import Prelude
import UrlFormEncoding

public protocol DerivePartialIsos {}

public enum Route: DerivePartialIsos {
  case about
  case account(Account)
  case admin(Admin)
  case episode(Either<String, Int>)
  case expressUnsubscribe(userId: Database.User.Id, newsletter: Database.EmailSetting.Newsletter)
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

  public enum Account: DerivePartialIsos {
    case confirmEmailChange(userId: Database.User.Id, emailAddress: EmailAddress)
    case index
    case paymentInfo(PaymentInfo)
    case subscription(Subscription)
    case update(ProfileData?)

    public enum PaymentInfo: DerivePartialIsos {
      case show
      case update(Stripe.Token.Id?)
    }

    public enum Subscription: DerivePartialIsos {
      case cancel(Cancel)
      case changeSeats(ChangeSeats)
      case downgrade(Downgrade)
      case reactivate
      case upgrade(Upgrade)

      public enum Cancel: DerivePartialIsos {
        case show
        case update
      }

      public enum ChangeSeats: DerivePartialIsos {
        case show
        case update
      }

      public enum Downgrade: DerivePartialIsos {
        case show
        case update
      }

      public enum Upgrade: DerivePartialIsos {
        case show
        case update
      }
    }
  }

  public enum Admin: DerivePartialIsos {
    case index
    case newEpisodeEmail(NewEpisodeEmail)

    public enum NewEpisodeEmail: DerivePartialIsos {
      case send(Episode.Id)
      case show
    }
  }

  public enum Invite: DerivePartialIsos {
    case accept(Database.TeamInvite.Id)
    case resend(Database.TeamInvite.Id)
    case revoke(Database.TeamInvite.Id)
    case send(EmailAddress?)
    case show(Database.TeamInvite.Id)
  }

  public enum Team: DerivePartialIsos {
    case remove(Database.User.Id)
    case show
  }
}

private let routers: [Router<Route>] = [

  Route.iso.about
    <¢> get %> lit("about") <% end,

  Route.iso.account <<< Route.Account.iso.confirmEmailChange
    <¢> get %> lit("account") %> lit("confirm-email-change")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, .tagged))
    <% end,

  Route.iso.account <<< Route.Account.iso.index
    <¢> get %> lit("account") <% end,

  Route.iso.account <<< Route.Account.iso.paymentInfo <<< Route.Account.PaymentInfo.iso.show
    <¢> get %> lit("account") %> lit("payment-info") <% end,

  Route.iso.account <<< Route.Account.iso.paymentInfo <<< Route.Account.PaymentInfo.iso.update
    <¢> post %> lit("account") %> lit("payment-info")
    %> formField("token", Optional.iso.some >>> opt(.string >>> .tagged))
    <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.cancel
    <<< Route.Account.Subscription.Cancel.iso.show
    <¢> get %> lit("account") %> lit("subscription") %> lit("cancel") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.cancel
    <<< Route.Account.Subscription.Cancel.iso.update
    <¢> post %> lit("account") %> lit("subscription") %> lit("cancel") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.changeSeats
    <<< Route.Account.Subscription.ChangeSeats.iso.show
    <¢> get %> lit("account") %> lit("subscription") %> lit("change-seats") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.changeSeats
    <<< Route.Account.Subscription.ChangeSeats.iso.update
    <¢> post %> lit("account") %> lit("subscription") %> lit("change-seats") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.downgrade
    <<< Route.Account.Subscription.Downgrade.iso.show
    <¢> get %> lit("account") %> lit("subscription") %> lit("downgrade") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.downgrade
    <<< Route.Account.Subscription.Downgrade.iso.update
    <¢> post %> lit("account") %> lit("subscription") %> lit("downgrade") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.reactivate
    <¢> post %> lit("account") %> lit("subscription") %> lit("reactivate") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.upgrade
    <<< Route.Account.Subscription.Upgrade.iso.show
    <¢> get %> lit("account") %> lit("subscription") %> lit("upgrade") <% end,

  Route.iso.account <<< Route.Account.iso.subscription <<< Route.Account.Subscription.iso.upgrade
    <<< Route.Account.Subscription.Upgrade.iso.update
    <¢> post %> lit("account") %> lit("subscription") %> lit("upgrade") <% end,

  Route.iso.account <<< Route.Account.iso.update
    <¢> post %> lit("account") %> formBody(ProfileData?.self, decoder: formDecoder) <% end,

  Route.iso.admin <<< Route.Admin.iso.index
    <¢> get %> lit("admin") <% end,

  Route.iso.admin <<< Route.Admin.iso.newEpisodeEmail <<< Route.Admin.NewEpisodeEmail.iso.send
    <¢> post %> lit("admin") %> lit("new-episode-email") %> pathParam(.int >>> .tagged) <% lit("send") <% end,

  Route.iso.admin <<< Route.Admin.iso.newEpisodeEmail <<< Route.Admin.NewEpisodeEmail.iso.show
    <¢> get %> lit("admin") %> lit("new-episode-email") <% end,

  Route.iso.episode
    <¢> get %> lit("episodes") %> pathParam(.intOrString) <% end,

  Route.iso.expressUnsubscribe
    <¢> get %> lit("newsletters") %> lit("express-unsubscribe")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, ._rawRepresentable))
    <% end,

  Route.iso.gitHubCallback
    <¢> get %> lit("github-auth")
    %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
    <% end,

  Route.iso.home
    <¢> get %> queryParam("success", opt(.bool)) <% end,

  Route.iso.invite <<< Route.Invite.iso.accept
    <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("accept") <% end,

  Route.iso.invite <<< Route.Invite.iso.resend
    <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("resend") <% end,

  Route.iso.invite <<< Route.Invite.iso.revoke
    <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("revoke") <% end,

  Route.iso.invite <<< Route.Invite.iso.send
    // TODO: this weird Optional.iso.some is cause `formField` takes a partial iso `String -> A` instead of
    //       `(String?) -> A` like it is for `queryParam`.
    <¢> post %> lit("invites") %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

  Route.iso.invite <<< Route.Invite.iso.show
    <¢> get %> lit("invites") %> pathParam(._rawRepresentable >>> ._rawRepresentable) <% end,

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
    %> pathParam(._rawRepresentable >>> ._rawRepresentable)
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
  return router.absoluteString(for: route) ?? "/"
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
