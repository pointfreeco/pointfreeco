import ApplicativeRouter
import Either
import Foundation
import Models
import PointFreePrelude
import Prelude
import Stripe
import Tagged
import UrlFormEncoding

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum Route: DerivePartialIsos, Equatable {
  case about
  case account(Account)
  case admin(Admin)
  case api(Api)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog)
  case discounts(code: Stripe.Coupon.Id, Pricing.Billing?)
  case enterprise(Enterprise)
  case episode(Either<String, Episode.Id>)
  case episodes
  case expressUnsubscribe(payload: Encrypted<String>)
  case expressUnsubscribeReply(MailgunForwardPayload)
  case feed(Feed)
  case gitHubCallback(code: String?, redirect: String?)
  case home
  case invite(Invite)
  case login(redirect: String?)
  case logout
  case pricingLanding
  case privacy
  case subscribe(SubscribeData?)
  case subscribeConfirmation(Pricing.Lane, Pricing.Billing?, [EmailAddress]?)
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

  public enum Enterprise: DerivePartialIsos, Equatable {
    case acceptInvite(EnterpriseAccount.Domain, email: Encrypted<String>, userId: Encrypted<String>)
    case landing(EnterpriseAccount.Domain)
    case requestInvite(EnterpriseAccount.Domain, EnterpriseRequestFormData)
  }

  public enum Feed: DerivePartialIsos, Equatable {
    case atom
    case episodes
  }

  public enum Invite: DerivePartialIsos, Equatable {
    case accept(TeamInvite.Id)
    case addTeammate(EmailAddress?)
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

extension PartialIso {
  public init(case: @escaping (A) -> B) {
    self.init(apply: `case`) { root in
      guard
        let (label, anyValue) = Mirror(reflecting: root).children.first,
        let value = anyValue as? A
          ?? Mirror(reflecting: anyValue).children.first?.value as? A,
        Mirror(reflecting: `case`(value)).children.first?.label == label
        else { return nil }
      return value
    }
  }
}

extension PartialIso where A == String {
  public static func array<C>(of iso: PartialIso<A, C>) -> PartialIso where B == Array<C> {
    return PartialIso(
      apply: { $0.split(separator: ",", omittingEmptySubsequences: false).compactMap { iso.apply(String($0)) } },
      unapply: { $0.compactMap(iso.unapply).joined(separator: ",") }
    )
  }
}

let routers: [Router<Route>] = [
  .about
    <¢> get %> lit("about") <% end,

  .account
    <¢> lit("account") %> accountRouter,

  .admin
    <¢> lit("admin") %> adminRouter,

  .api
    <¢> "api" %> apiRouter,

  .appleDeveloperMerchantIdDomainAssociation
    <¢> get %> lit(".well-known") %> lit("apple-developer-merchantid-domain-association"),

  .blog <<< .feed
    <¢> get %> lit("blog") %> lit("feed") %> lit("atom.xml") <% end,

  .discounts
    <¢> get %> lit("discounts")
    %> pathParam(.tagged(.string))
    <%> queryParam("billing", opt(.rawRepresentable))
    <% end,

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

  .enterprise <<< PartialIso.acceptInvite
    <¢> get %> "enterprise" %> pathParam(.tagged) <%> "accept"
    %> queryParam("email", .tagged)
    <%> queryParam("user_id", .tagged)
    <% end,

  .enterprise <<< .landing
    <¢> get %> "enterprise" %> pathParam(.tagged(.string)) <% end,

  .enterprise <<< .requestInvite
    <¢> post %> "enterprise" %> pathParam(.tagged(.string)) <%> "request"
    %> formBody(EnterpriseRequestFormData.self, decoder: formDecoder) <% end,

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

  .invite <<< .addTeammate
    <¢> post %> lit("invites") %> lit("add") %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

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

  .pricingLanding
    <¢> get %> lit("pricing") <% end,

  .privacy
    <¢> get %> lit("privacy") <% end,

  .subscribe
    <¢> post %> lit("subscribe") %> stringBody.map(subscriberDataIso) <% end,

  PartialIso.subscribeConfirmation
    <¢> get %> lit("subscribe")
    %> pathParam(.rawRepresentable)
    <%> queryParam("billing", opt(.rawRepresentable))
    <%> queryParam("teammates", opt(.array(of: .rawRepresentable)))
    <% end,

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

private let subscriberDataIso = PartialIso<String, SubscribeData?>(
  apply: { str in
    let keyValues = parse(query: str)

    guard
      let billing = keyValues.first(where: { key, value in key == "pricing[billing]" })?.1.flatMap(Pricing.Billing.init(rawValue:)),
      let quantity = keyValues.first(where: { key, value in key == "pricing[quantity]" })?.1.flatMap(Int.init),
      let token = keyValues.first(where: { key, value in key == "token" })?.1.flatMap(Token.Id.init(rawValue:))
      else {
        return nil
    }

    let rawCouponValue = keyValues.first(where: { key, value in key == "coupon" })?.1
    let coupon = rawCouponValue == "" ? nil : rawCouponValue.flatMap(Coupon.Id.init(rawValue:))
    let teammates = keyValues.filter({ key, value in key.prefix(9) == "teammates" })
      .compactMap { _, value in value }
      .map(EmailAddress.init(rawValue:))

    return SubscribeData(
      coupon: coupon,
      pricing: Pricing(billing: billing, quantity: quantity),
      teammates: teammates,
      token: token
    )
},
  unapply: { data in
    guard let data = data else { return nil }
    var parts: [String] = []
    if let coupon = data.coupon {
      parts.append("coupon=\(coupon.rawValue)")
    }
    parts.append("pricing[billing]=\(data.pricing.billing.rawValue)")
    parts.append("pricing[quantity]=\(data.pricing.quantity)")
    parts.append(contentsOf: (zip(0..., data.teammates).map { idx, email in "teammates[\(idx)]=\(email)" }))
    parts.append("token=\(data.token.rawValue)")
    return parts.joined(separator: "&")
}
)
