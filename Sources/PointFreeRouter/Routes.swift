import ApplicativeRouter
import Either
import EmailAddress
import Foundation
import Models
import PointFreePrelude
import Prelude
import Stripe
import Tagged
import UrlFormEncoding

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum Route: Equatable {
  case about
  case account(Account)
  case admin(Admin)
  case api(Api)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog)
  case discounts(code: Stripe.Coupon.Id, Pricing.Billing?)
  case endGhosting
  case enterprise(Enterprise)
  case episode(EpisodeRoute)
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
  case subscribeConfirmation(
    lane: Pricing.Lane,
    billing: Pricing.Billing?,
    isOwnerTakingSeat: Bool?,
    teammates: [EmailAddress]?,
    referralCode: User.ReferralCode?
  )
  case team(Team)
  case useEpisodeCredit(Episode.Id)
  case webhooks(Webhooks)

  public enum Blog: Equatable {
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

  public enum Enterprise: Equatable {
    case acceptInvite(EnterpriseAccount.Domain, email: Encrypted<String>, userId: Encrypted<String>)
    case landing(EnterpriseAccount.Domain)
    case requestInvite(EnterpriseAccount.Domain, EnterpriseRequestFormData)
  }

  public enum EpisodeRoute: Equatable {
    case index
    case progress(param: Either<String, Episode.Id>, percent: Int)
    case show(Either<String, Episode.Id>)
  }

  public enum Feed: Equatable {
    case atom
    case episodes
  }

  public enum Invite: Equatable {
    case accept(TeamInvite.Id)
    case addTeammate(EmailAddress?)
    case resend(TeamInvite.Id)
    case revoke(TeamInvite.Id)
    case send(EmailAddress?)
    case show(TeamInvite.Id)
  }

  public enum Team: Equatable {
    case join(User.TeamInviteCode)
    case joinLanding(User.TeamInviteCode)
    case leave
    case remove(User.Id)
  }

  public enum Webhooks: Equatable {
    case stripe(_Stripe)

    public enum _Stripe: Equatable {
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
  .case(.about)
    <¢> get %> "about" <% end,

  .case(Route.account)
    <¢> "account" %> accountRouter,

  .case(Route.admin)
    <¢> "admin" %> adminRouter,

  .case(Route.api)
    <¢> "api" %> apiRouter,

  .case(.appleDeveloperMerchantIdDomainAssociation)
    <¢> get %> ".well-known" %> "apple-developer-merchantid-domain-association",

  .case(.blog(.feed))
    <¢> get %> "blog" %> "feed" %> "atom.xml" <% end,

  .case(Route.discounts)
    <¢> get %> "discounts"
    %> pathParam(.tagged(.string))
    <%> queryParam("billing", opt(.rawRepresentable))
    <% end,

  .case(.endGhosting)
    <¢> post %> "ghosting" %> "end" <% end,

  .case(.blog(.index))
    <¢> get %> "blog" <% end,

  .case { .blog(.show($0)) }
    <¢> get %> "blog" %> "posts" %> pathParam(.blogPostIdOrString) <% end,

  .case(.episode(.index))
    <¢> get %> "episodes" <% end,

  parenthesize(.case { .episode(.progress(param: $0, percent: $1)) })
    <¢> post %> "episodes" %> pathParam(.episodeIdOrString) <%> "progress"
    %> queryParam("percent", .int)
    <% end,

  .case { .episode(.show($0)) }
    <¢> get %> "episodes" %> pathParam(.episodeIdOrString) <% end,

  .case(.feed(.atom))
    <¢> get %> "feed" %> "atom.xml" <% end,

  .case(.feed(.episodes))
    <¢> (get <|> head) %> "feed" %> "episodes.xml" <% end,

  parenthesize(.case { .enterprise(.acceptInvite($0, email: $1, userId: $2)) })
    <¢> get %> "enterprise" %> pathParam(.tagged) <%> "accept"
    %> queryParam("email", .tagged)
    <%> queryParam("user_id", .tagged)
    <% end,

  .case { .enterprise(.landing($0)) }
    <¢> get %> "enterprise" %> pathParam(.tagged(.string)) <% end,

  .case { .enterprise(.requestInvite($0, $1)) }
    <¢> post %> "enterprise" %> pathParam(.tagged(.string)) <%> "request"
    %> formBody(EnterpriseRequestFormData.self, decoder: formDecoder) <% end,

  .case(Route.expressUnsubscribe)
    <¢> get %> "newsletters" %> "express-unsubscribe"
    %> queryParam("payload", .tagged)
    <% end,

  .case(Route.expressUnsubscribeReply)
    <¢> post %> "newsletters" %> "express-unsubscribe-reply"
    %> formBody(MailgunForwardPayload.self, decoder: formDecoder)
    <% end,

  .case(Route.gitHubCallback)
    <¢> get %> "github-auth"
    %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
    <% end,

  .case(.home)
    <¢> get <% end,

  .case { .invite(.accept($0)) }
    <¢> post %> "invites" %> pathParam(.tagged(.uuid)) <% "accept" <% end,

  .case { .invite(.addTeammate($0)) }
    <¢> post %> "invites" %> "add" %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

  .case { .invite(.resend($0)) }
    <¢> post %> "invites" %> pathParam(.tagged(.uuid)) <% "resend" <% end,

  .case { .invite(.revoke($0)) }
    <¢> post %> "invites" %> pathParam(.tagged(.uuid)) <% "revoke" <% end,

  .case { .invite(.send($0)) }
    // TODO: this weird Optional.iso.some is cause `formField` takes a partial iso `String -> A` instead of
    //       `(String?) -> A` like it is for `queryParam`.
    <¢> post %> "invites" %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

  .case { .invite(.show($0)) }
    <¢> get %> "invites" %> pathParam(.tagged(.uuid)) <% end,

  .case(Route.login)
    <¢> get %> "login" %> queryParam("redirect", opt(.string)) <% end,

  .case(.logout)
    <¢> get %> "logout" <% end,

  .case(.pricingLanding)
    <¢> get %> "pricing" <% end,

  .case(.privacy)
    <¢> get %> "privacy" <% end,

  .case(Route.subscribe)
    <¢> post %> "subscribe" %> stringBody.map(subscriberDataIso) <% end,

  parenthesize(.case(Route.subscribeConfirmation))
    <¢> get %> "subscribe"
    %> pathParam(.rawRepresentable)
    <%> queryParam("billing", opt(.rawRepresentable))
    <%> queryParam("isOwnerTakingSeat", opt(.bool))
    <%> queryParam("teammates", opt(.array(of: .rawRepresentable)))
    <%> queryParam("ref", opt(.tagged(.string)))
    <% end,

  .case { .team(.join($0)) }
    <¢> post %> "team" %> pathParam(.tagged(.string)) <% "join"
    <% end,

  .case { .team(.joinLanding($0)) }
    <¢> get %> "team" %> pathParam(.tagged(.string)) <% "join"
    <% end,

  .case(.team(.leave))
    <¢> post %> "account" %> "team" %> "leave"
    <% end,

  .case { .team(.remove($0)) }
    <¢> post %> "account" %> "team" %> "members" %> pathParam(.tagged(.uuid)) <% "remove"
    <% end,

  .case(Route.useEpisodeCredit)
    <¢> post %> "episodes" %> pathParam(.tagged(.int)) <% "credit" <% end,

  .case { .webhooks(.stripe(.knownEvent($0))) }
    <¢> post %> "webhooks" %> "stripe"
    %> jsonBody(
      Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
      encoder: Stripe.jsonEncoder,
      decoder: Stripe.jsonDecoder
    )
    <% end,

  .case { .webhooks(.stripe(.unknownEvent($0))) }
    <¢> post %> "webhooks" %> "stripe"
    %> jsonBody(
      Stripe.Event<Prelude.Unit>.self,
      encoder: Stripe.jsonEncoder,
      decoder: Stripe.jsonDecoder
    )
    <% end,

  .case(.webhooks(.stripe(.fatal)))
    <¢> post %> "webhooks" %> "stripe" <% end,
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
      let billing = keyValues.first(where: { k, _ in k == "pricing[billing]" })?.1.flatMap(Pricing.Billing.init),
      let quantity = keyValues.first(where: { k, _ in k == "pricing[quantity]" })?.1.flatMap(Int.init),
      let token = keyValues.first(where: { k, _ in k == "token" })?.1.flatMap(Token.Id.init)
      else {
        return nil
    }

    let isOwnerTakingSeat = keyValues
      .first { k, _ in k == SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue }?.1
      .flatMap(Bool.init)
      ?? false

    let rawCouponValue = keyValues.first(where: { key, value in key == "coupon" })?.1
    let coupon = rawCouponValue == "" ? nil : rawCouponValue.flatMap(Coupon.Id.init(rawValue:))
    let referralCode = keyValues
      .first(where: { key, _ in key == SubscribeData.CodingKeys.referralCode.rawValue })?.1
      .flatMap(User.ReferralCode.init)
    let teammates = keyValues.filter({ key, value in key.prefix(9) == "teammates" })
      .compactMap { _, value in value }
      .map(EmailAddress.init(rawValue:))

    return SubscribeData(
      coupon: coupon,
      isOwnerTakingSeat: isOwnerTakingSeat,
      pricing: Pricing(billing: billing, quantity: quantity),
      referralCode: referralCode,
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
    parts.append("isOwnerTakingSeat=\(data.isOwnerTakingSeat)")
    parts.append("pricing[billing]=\(data.pricing.billing.rawValue)")
    parts.append("pricing[quantity]=\(data.pricing.quantity)")
    parts.append(contentsOf: (zip(0..., data.teammates).map { idx, email in "teammates[\(idx)]=\(email)" }))
    parts.append("token=\(data.token.rawValue)")
    if let referralCode = data.referralCode?.rawValue {
      parts.append("\(SubscribeData.CodingKeys.referralCode.rawValue)=\(referralCode)")
    }
    return parts.joined(separator: "&")
}
)
