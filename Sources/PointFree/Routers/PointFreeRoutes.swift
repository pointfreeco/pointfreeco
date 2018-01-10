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
  case feed(Feed)
  case gitHubCallback(code: String?, redirect: String?)
  case home(signedUpSuccessfully: Bool?)
  case invite(Invite)
  case launchSignup(EmailAddress)
  case login(redirect: String?)
  case logout
  case pricing(String?, Int?)
  case privacy
  case secretHome
  case subscribe(SubscribeData?)
  case team(Team)

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
        case update(Int?)
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

  public enum Feed: DerivePartialIsos {
    case atom
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

  .about
    <¢> get %> lit("about") <% end,

  .account <<< .confirmEmailChange
    <¢> get %> lit("account") %> lit("confirm-email-change")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, .tagged))
    <% end,

  .account <<< .index
    <¢> get %> lit("account") <% end,

  .account <<< .paymentInfo <<< .show
    <¢> get %> lit("account") %> lit("payment-info") <% end,

  .account <<< .paymentInfo <<< .update
    <¢> post %> lit("account") %> lit("payment-info")
    %> formField("token", Optional.iso.some >>> opt(.string >>> .tagged))
    <% end,

  .account <<< .subscription <<< .cancel <<< .show
    <¢> get %> lit("account") %> lit("subscription") %> lit("cancel") <% end,

  .account <<< .subscription <<< .cancel <<< .update
    <¢> post %> lit("account") %> lit("subscription") %> lit("cancel") <% end,

  .account <<< .subscription <<< .changeSeats <<< .show
    <¢> get %> lit("account") %> lit("subscription") %> lit("change-seats") <% end,

  .account <<< .subscription <<< .changeSeats <<< .update
    <¢> post %> lit("account") %> lit("subscription") %> lit("change-seats")
    %> formField("quantity", Optional.iso.some >>> opt(.int))
    <% end,

  .account <<< .subscription <<< .downgrade <<< .show
    <¢> get %> lit("account") %> lit("subscription") %> lit("downgrade") <% end,

  .account <<< .subscription <<< .downgrade <<< .update
    <¢> post %> lit("account") %> lit("subscription") %> lit("downgrade") <% end,

  .account <<< .subscription <<< .reactivate
    <¢> post %> lit("account") %> lit("subscription") %> lit("reactivate") <% end,

  .account <<< .subscription <<< .upgrade <<< .show
    <¢> get %> lit("account") %> lit("subscription") %> lit("upgrade") <% end,

  .account <<< .subscription <<< .upgrade <<< .update
    <¢> post %> lit("account") %> lit("subscription") %> lit("upgrade") <% end,

  .account <<< .update
    <¢> post %> lit("account") %> formBody(ProfileData?.self, decoder: formDecoder) <% end,

  .admin <<< .index
    <¢> get %> lit("admin") <% end,

  .admin <<< .newEpisodeEmail <<< .send
    <¢> post %> lit("admin") %> lit("new-episode-email") %> pathParam(.int >>> .tagged) <% lit("send") <% end,

  .admin <<< .newEpisodeEmail <<< .show
    <¢> get %> lit("admin") %> lit("new-episode-email") <% end,

  .episode
    <¢> get %> lit("episodes") %> pathParam(.intOrString) <% end,

  .feed <<< .atom
    <¢> get %> lit("feed") %> lit("atom.xml") <% end,

  .expressUnsubscribe
    <¢> get %> lit("newsletters") %> lit("express-unsubscribe")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, ._rawRepresentable))
    <% end,

  .gitHubCallback
    <¢> get %> lit("github-auth")
    %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
    <% end,

  .home
    <¢> get %> queryParam("success", opt(.bool)) <% end,

  .invite <<< .accept
    <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("accept") <% end,

  .invite <<< .resend
    <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("resend") <% end,

  .invite <<< .revoke
    <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("revoke") <% end,

  .invite <<< .send
    // TODO: this weird Optional.iso.some is cause `formField` takes a partial iso `String -> A` instead of
    //       `(String?) -> A` like it is for `queryParam`.
    <¢> post %> lit("invites") %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

  .invite <<< .show
    <¢> get %> lit("invites") %> pathParam(._rawRepresentable >>> ._rawRepresentable) <% end,

  .launchSignup
    <¢> post %> formField("email", .rawRepresentable) <% lit("launch-signup") <% end,

  .login
    <¢> get %> lit("login") %> queryParam("redirect", opt(.string)) <% end,

  .logout
    <¢> get %> lit("logout") <% end,

  .pricing
    <¢> get %> lit("pricing") %> queryParam("plan", opt(.string)) <%> queryParam("quantity", opt(.int)) <% end,

  .privacy
    <¢> get %> lit("privacy") <% end,

  .secretHome
    <¢> get %> lit("home") <% end,

  .subscribe
    <¢> post %> lit("subscribe") %> formBody(SubscribeData?.self, decoder: formDecoder) <% end,

  .team <<< .remove
    <¢> post %> lit("account") %> lit("team") %> lit("members")
    %> pathParam(._rawRepresentable >>> ._rawRepresentable)
    <% lit("remove")
    <% end,

  .team <<< .show
    <¢> get %> lit("account") %> lit("team") <% end,
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
