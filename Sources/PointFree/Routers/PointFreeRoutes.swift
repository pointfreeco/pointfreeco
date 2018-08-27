import ApplicativeRouter
import Foundation
import Either
import HttpPipeline
import Optics
import Prelude
import UrlFormEncoding

public protocol DerivePartialIsos {}

public enum Route: DerivePartialIsos {
  case about
  case account(Account)
  case admin(Admin)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog)
  case discounts(organization: String)
  case episode(Either<String, Int>)
  case episodes
  case expressUnsubscribe(userId: Database.User.Id, newsletter: Database.EmailSetting.Newsletter)
  case expressUnsubscribeReply(MailgunForwardPayload)
  case feed(Feed)
  case fika
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

  public enum Blog: DerivePartialIsos {
    case feed(Feed)
    case index
    case show(BlogPost)
  }

  public enum Account: DerivePartialIsos {
    case confirmEmailChange(userId: Database.User.Id, emailAddress: EmailAddress)
    case index
    case invoices(Invoices)
    case paymentInfo(PaymentInfo)
    case subscription(Subscription)
    case update(ProfileData?)

    public enum Invoices: DerivePartialIsos {
      case index
      case show(Stripe.Invoice.Id)
    }

    public enum PaymentInfo: DerivePartialIsos {
      case show(expand: Bool?)
      case update(Stripe.Token.Id?)
    }

    public enum Subscription: DerivePartialIsos {
      case cancel
      case change(Change)
      case reactivate

      public enum Change: DerivePartialIsos {
        case show
        case update(Pricing?)
      }
    }
  }

  public enum Admin: DerivePartialIsos {
    case episodeCredits(EpisodeCredit)
    case freeEpisodeEmail(FreeEpisodeEmail)
    case index
    case newBlogPostEmail(NewBlogPostEmail)
    case newEpisodeEmail(NewEpisodeEmail)

    public enum EpisodeCredit: DerivePartialIsos {
      case add(userId: Database.User.Id?, episodeSequence: Int?)
      case show
    }

    public enum FreeEpisodeEmail: DerivePartialIsos {
      case send(Episode.Id)
      case index
    }

    public enum NewBlogPostEmail: DerivePartialIsos {
      case send(BlogPost, subscriberAnnouncement: String?, nonSubscriberAnnouncement: String?, isTest: Bool?)
      case index
    }

    public enum NewEpisodeEmail: DerivePartialIsos {
      case send(Episode.Id, subscriberAnnouncement: String?, nonSubscriberAnnouncement: String?, isTest: Bool?)
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
    case leave
    case remove(Database.User.Id)
  }

  public enum Webhooks: DerivePartialIsos {
    case stripe(Stripe)

    public enum Stripe: DerivePartialIsos {
      case event(PointFree.Stripe.Event<Either<PointFree.Stripe.Invoice, PointFree.Stripe.Subscription>>)
      case `fallthrough`
    }
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

  .account <<< .invoices <<< .index
    <¢> get %> lit("account") %> lit("invoices") <% end,

  .account <<< .invoices <<< .show
    <¢> get %> lit("account") %> lit("invoices") %> pathParam(.string >>> .tagged) <% end,

  .account <<< .paymentInfo <<< .show
    <¢> get %> lit("account") %> lit("payment-info")
    %> queryParam("expand", opt(.bool))
    <% end,

  .account <<< .paymentInfo <<< .update
    <¢> post %> lit("account") %> lit("payment-info")
    %> formField("token", Optional.iso.some >>> opt(.string >>> .tagged))
    <% end,

  .account <<< .subscription <<< .cancel
    <¢> post %> lit("account") %> lit("subscription") %> lit("cancel") <% end,

  .account <<< .subscription <<< .change <<< .show
    <¢> get %> lit("account") %> lit("subscription") %> lit("change") <% end,

  .account <<< .subscription <<< .change <<< .update
    <¢> post %> lit("account") %> lit("subscription") %> lit("change")
    %> formBody(Pricing?.self, decoder: formDecoder)
    <% end,

  .account <<< .subscription <<< .reactivate
    <¢> post %> lit("account") %> lit("subscription") %> lit("reactivate") <% end,

  .account <<< .update
    <¢> post %> lit("account") %> formBody(ProfileData?.self, decoder: formDecoder) <% end,

  .admin <<< .episodeCredits <<< .add
    <¢> post %> lit("admin") %> lit("episode-credits") %> lit("add")
    %> formField("user_id", Optional.iso.some >>> opt(.uuid >>> .tagged))
    <%> formField("episode_sequence", Optional.iso.some >>> opt(.int))
    <% end,

  .admin <<< .episodeCredits <<< .show
    <¢> get %> lit("admin") %> lit("episode-credits") %> end,

  .admin <<< .index
    <¢> get %> lit("admin") <% end,

  .admin <<< .freeEpisodeEmail <<< .send
    <¢> post %> lit("admin") %> lit("free-episode-email") %> pathParam(.int >>> .tagged) <% lit("send") <% end,

  .admin <<< .freeEpisodeEmail <<< .index
    <¢> get %> lit("admin") %> lit("free-episode-email") <% end,

  .admin <<< .newBlogPostEmail <<< .index
    <¢> get %> lit("admin") %> lit("new-blog-post-email") <% end,

  .admin <<< .newBlogPostEmail <<< PartialIso.send
    <¢> post %> lit("admin") %> lit("new-blog-post-email") %> pathParam(.int >>> .tagged >>> .blogPostFromId) <%> lit("send")
    %> formField("subscriber_announcement", .string).map(Optional.iso.some)
    <%> formField("nonsubscriber_announcement", .string).map(Optional.iso.some)
    <%> isTest
    <% end,

  .admin <<< .newEpisodeEmail <<< PartialIso.send
    <¢> post %> lit("admin") %> lit("new-episode-email") %> pathParam(.int >>> .tagged) <%> lit("send")
    %> formField("subscriber_announcement", .string).map(Optional.iso.some)
    <%> formField("nonsubscriber_announcement", .string).map(Optional.iso.some)
    <%> isTest
    <% end,

  .admin <<< .newEpisodeEmail <<< .show
    <¢> get %> lit("admin") %> lit("new-episode-email") <% end,

  .appleDeveloperMerchantIdDomainAssociation
    <¢> get %> lit(".well-known") %> lit("apple-developer-merchantid-domain-association"),

  .blog <<< .feed <<< .atom
    <¢> get %> lit("blog") %> lit("feed") %> lit("atom.xml") <% end,

  .discounts
    <¢> get %> lit("discounts") %> .string <% end,

  .blog <<< .index
    <¢> get %> lit("blog") <% end,

  .blog <<< .show
    <¢> get %> lit("blog") %> lit("posts") %> pathParam(.intOrString >>> .blogPostFromParam) <% end,

  .episode
    <¢> get %> lit("episodes") %> pathParam(.intOrString) <% end,

  .episodes
    <¢> get %> lit("episodes") <% end,

  .feed <<< .atom
    <¢> get %> lit("feed") %> lit("atom.xml") <% end,

  .fika
    <¢> get %> lit("fika") <% end,

  .expressUnsubscribe
    <¢> get %> lit("newsletters") %> lit("express-unsubscribe")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, .rawRepresentable))
    <% end,

  .expressUnsubscribeReply
    <¢> post %> lit("newsletters") %> lit("express-unsubscribe-reply")
    %> formBody(MailgunForwardPayload.self, decoder: formDecoder).map(.signatureVerification)
    <% end,

  .gitHubCallback
    <¢> get %> lit("github-auth")
    %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
    <% end,

  .home
    <¢> get <% end,

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
    <¢> get %> lit("invites") %> pathParam(.rawRepresentable >>> .rawRepresentable) <% end,

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
    %> pathParam(.uuid >>> .tagged)
    <% lit("remove")
    <% end,

  .useEpisodeCredit
    <¢> post %> lit("episodes") %> pathParam(.int >>> .tagged) <% lit("credit") <% end,

  .webhooks <<< .stripe <<< .event
    <¢> post %> lit("webhooks") %> lit("stripe")
    %> jsonBody(
      Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
      encoder: stripeJsonEncoder,
      decoder: stripeJsonDecoder
    )
    <% end,

  .webhooks <<< .stripe <<< .fallthrough
    <¢> post %> lit("webhooks") %> lit("stripe") <% end,
]

private let formDecoder = UrlFormDecoder()
  |> \.parsingStrategy .~ .bracketsWithIndices

public let router = routers.reduce(.empty, <|>)

public func path(to route: Route) -> String {
  return router.absoluteString(for: route) ?? "/"
}

public func url(to route: Route) -> String {
  return router.url(for: route, base: Current.envVars.baseUrl)?.absoluteString ?? ""
}

extension PartialIso where A == String, B == Tag {
  public static var tag: PartialIso<String, Tag> {
    return PartialIso<String, Tag>(
      apply: Tag.init(slug:),
      unapply: ^\.name
    )
  }
}

public struct MailgunForwardPayload: Codable {
  public let recipient: EmailAddress
  public let timestamp: Int
  public let token: String
  public let sender: EmailAddress
  public let signature: String
}

extension PartialIso where A == MailgunForwardPayload, B == MailgunForwardPayload {
  fileprivate static var signatureVerification: PartialIso {
    return PartialIso(
      apply: { verify(payload: $0) ? .some($0) : nil },
      unapply: { $0 }
    )
  }
}

private func verify(payload: MailgunForwardPayload) -> Bool {
  let digest = hexDigest(
    value: "\(payload.timestamp)\(payload.token)",
    asciiSecret: Current.envVars.mailgun.apiKey
  )
  return payload.signature == digest
}

extension PartialIso where A == (String?, Int?), B == Pricing {
  fileprivate static var pricing: PartialIso {
    return PartialIso(
      apply: { plan, quantity in
        let billing = plan.flatMap(Pricing.Billing.init(rawValue:)) ?? .monthly
        let quantity = clamp(1..<Pricing.validTeamQuantities.upperBound) <| (quantity ?? 1)
        return Pricing(billing: billing, quantity: quantity)
    }, unapply: { pricing -> (String?, Int?) in
      (pricing.billing.rawValue, pricing.quantity)
    })
  }
}

private let isTest: Router<Bool?> =
  formField("live", .string).map(isPresent >>> negate >>> Optional.iso.some)
    <|> formField("test", .string).map(isPresent >>> Optional.iso.some)

private let isPresent = PartialIso<String, Bool>(apply: const(true), unapply: { $0 ? "" : nil })
private let negate = PartialIso<Bool, Bool>(apply: (!), unapply: (!))
