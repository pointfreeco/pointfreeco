import ApplicativeRouter
import Either
import Foundation
import Models
import PointFreePrelude
import Prelude
import Stripe

public struct PointFreeRouter {
  private let baseUrl: URL
  private let router: Router<Route>

  public init(baseUrl: URL, router: Router<Route>) {
    self.baseUrl = baseUrl
    self.router = router
  }

  public func path(to route: Route) -> String {
    return self.router.absoluteString(for: route) ?? "/"
  }

  public func url(to route: Route) -> String {
    return self.router.url(for: route, base: self.baseUrl)?.absoluteString ?? ""
  }
}

public var _pointFreeRouter: PointFreeRouter!
public let pointFreeRouter = routers.reduce(.empty, <|>)

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum Route: DerivePartialIsos, Equatable {
  case about
  case account(Account)
  case admin(Admin)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog)
  case discounts(code: Stripe.Coupon.Id)
  case episode(Either<String, Episode.Id>)
  case episodes
  case expressUnsubscribe(payload: Encrypted<String>)
  case expressUnsubscribeReply(MailgunForwardPayload)
  case feed(Feed)
  case gitHubCallback(code: String?, redirect: String?)
  case invite(Invite)
  case login(redirect: String?)
  case logout
  case pricing(Pricing?, expand: Bool?)
  case privacy
  case home
  case subscribe(SubscribeData?)
  case team(Team)
  case useEpisodeCredit(Episode.Id)
  case webhooks(Webhooks)

  public enum Blog: DerivePartialIsos, Equatable {
    case feed
    case index
    case show(Either<String, BlogPost.Id>)

    public static func show(slug: String) -> Blog {
      return .show(.left(slug))
    }

    public static func show(id: BlogPost.Id) -> Blog {
      return .show(.right(id))
    }
  }

  public enum Feed: DerivePartialIsos, Equatable {
    case atom
    case episodes
  }

  public enum Invite: DerivePartialIsos, Equatable {
    case accept(TeamInvite.Id)
    case resend(TeamInvite.Id)
    case revoke(TeamInvite.Id)
    case send(EmailAddress?)
    case show(TeamInvite.Id)
  }

  public enum Team: DerivePartialIsos, Equatable {
    case leave
    case remove(User.Id)
  }

  public enum Webhooks: DerivePartialIsos, Equatable {
    case stripe(_Stripe)

    public enum _Stripe: DerivePartialIsos, Equatable {
      case knownEvent(Event<Either<Invoice, Stripe.Subscription>>)
      case unknownEvent(Event<Prelude.Unit>)
      case fatal
    }
  }
}

private let routers: [Router<Route>] = [
  .about
    <¢> get %> lit("about") <% end,

  .account
    <¢> lit("account") %> accountRouter,

  .admin
    <¢> lit("admin") %> adminRouter,

  .appleDeveloperMerchantIdDomainAssociation
    <¢> get %> lit(".well-known") %> lit("apple-developer-merchantid-domain-association"),

  .blog <<< .feed
    <¢> get %> lit("blog") %> lit("feed") %> lit("atom.xml") <% end,

  .discounts
    <¢> get %> lit("discounts") %> pathParam(.tagged(.string)) <% end,

  .blog <<< .index
    <¢> get %> lit("blog") <% end,

  .blog <<< .show
    <¢> get %> lit("blog") %> lit("posts") %> pathParam(.blogPostIdOrString) <% end,

  .episode
    <¢> get %> lit("episodes") %> pathParam(.episodeIdOrString) <% end,

  .episodes
    <¢> get %> lit("episodes") <% end,

  .feed <<< .atom
    <¢> get %> lit("feed") %> lit("atom.xml") <% end,

  .feed <<< .episodes
    <¢> (get <|> head) %> lit("feed") %> lit("episodes.xml") <% end,

  .expressUnsubscribe
    <¢> get %> lit("newsletters") %> lit("express-unsubscribe")
    %> queryParam("payload", .tagged)
    <% end,

  .expressUnsubscribeReply
    <¢> post %> lit("newsletters") %> lit("express-unsubscribe-reply")
    %> formBody(MailgunForwardPayload.self, decoder: formDecoder)
    <% end,

  .gitHubCallback
    <¢> get %> lit("github-auth")
    %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
    <% end,

  .home
    <¢> get <% end,

  .invite <<< .accept
    <¢> post %> lit("invites") %> pathParam(.tagged(.uuid)) <% lit("accept") <% end,

  .invite <<< .resend
    <¢> post %> lit("invites") %> pathParam(.tagged(.uuid)) <% lit("resend") <% end,

  .invite <<< .revoke
    <¢> post %> lit("invites") %> pathParam(.tagged(.uuid)) <% lit("revoke") <% end,

  .invite <<< .send
    // TODO: this weird Optional.iso.some is cause `formField` takes a partial iso `String -> A` instead of
    //       `(String?) -> A` like it is for `queryParam`.
    <¢> post %> lit("invites") %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

  .invite <<< .show
    <¢> get %> lit("invites") %> pathParam(.tagged(.uuid)) <% end,

  .login
    <¢> get %> lit("login") %> queryParam("redirect", opt(.string)) <% end,

  .logout
    <¢> get %> lit("logout") <% end,

  .pricing
    <¢> get %> lit("pricing")
    %> (queryParam("plan", opt(.string)) <%> queryParam("quantity", opt(.int)))
      .map(PartialIso.pricing >>> Optional.iso.some)
    <%> queryParam("expand", opt(.bool))
    <% end,

  .privacy
    <¢> get %> lit("privacy") <% end,

  .subscribe
    <¢> post %> lit("subscribe") %> formBody(SubscribeData?.self, decoder: formDecoder) <% end,

  .team <<< .leave
    <¢> post %> lit("account") %> lit("team") %> lit("leave")
    <% end,

  .team <<< .remove
    <¢> post %> lit("account") %> lit("team") %> lit("members")
    %> pathParam(.tagged(.uuid))
    <% lit("remove")
    <% end,

  .useEpisodeCredit
    <¢> post %> lit("episodes") %> pathParam(.tagged(.int)) <% lit("credit") <% end,

  .webhooks <<< .stripe <<< .knownEvent
    <¢> post %> lit("webhooks") %> lit("stripe")
    %> jsonBody(
      Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
      encoder: Stripe.jsonEncoder,
      decoder: Stripe.jsonDecoder
    )
    <% end,

  .webhooks <<< .stripe <<< .unknownEvent
    <¢> post %> lit("webhooks") %> lit("stripe")
    %> jsonBody(
      Stripe.Event<Prelude.Unit>.self,
      encoder: Stripe.jsonEncoder,
      decoder: Stripe.jsonDecoder
    )
    <% end,

  .webhooks <<< .stripe <<< .fatal
    <¢> post %> lit("webhooks") %> lit("stripe") <% end,
]

extension PartialIso {
  static func either<Left, Right>(
    _ l: PartialIso<A, Left>,
    _ r: PartialIso<A, Right>
    )
    -> PartialIso
    where B == Either<Left, Right> {
      return PartialIso(
        apply: { l.apply($0).map(Either.left) ?? r.apply($0).map(Either.right) },
        unapply: { $0.either(l.unapply, r.unapply) }
      )
  }
}

extension PartialIso where A == String, B == Either<String, BlogPost.Id> {
  static let blogPostIdOrString = either(.string, .tagged(.int))
}

extension PartialIso where A == String, B == Either<String, Episode.Id> {
  static var episodeIdOrString = either(.string, .tagged(.int))
}
