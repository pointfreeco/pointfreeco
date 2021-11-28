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
import URLRouting

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum Route: Equatable {
  case about
  case account(Account)
  case admin(Admin)
  case api(Api)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog)
  case collections(Collections)
  case discounts(code: Stripe.Coupon.Id, Pricing.Billing?)
  case gifts(Gifts)
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
    billing: Pricing.Billing? = nil,
    isOwnerTakingSeat: Bool? = nil,
    teammates: [EmailAddress]? = nil,
    referralCode: User.ReferralCode? = nil,
    useRegionalDiscount: Bool? = nil
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

  public enum Collections: Equatable {
    case episode(Episode.Collection.Slug, Episode.Collection.Section.Slug, Either<String, Episode.Id>)
    case index
    case show(Episode.Collection.Slug)
    case section(Episode.Collection.Slug, Episode.Collection.Section.Slug)
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
    case join(Models.Subscription.TeamInviteCode)
    case joinLanding(Models.Subscription.TeamInviteCode)
    case leave
    case remove(User.Id)
  }

  public enum Webhooks: Equatable {
    case stripe(_Stripe)

    public enum _Stripe: Equatable {
      case paymentIntents(Event<PaymentIntent>)
      case subscriptions(Event<Either<Invoice, Stripe.Subscription>>)
      case unknown(Event<Prelude.Unit>)
      case fatal
    }
  }
}

private let blogSlugOrId = OneOf {
  String.parser(of: Substring.self)
    .pipe(/Either<String, BlogPost.Id>.left)

  Int.parser(of: Substring.self)
    .pipe { BlogPost.Id.parser() }
    .pipe(/Either<String, BlogPost.Id>.right)
}

private let blogRouter = OneOf {
  Routing(/Route.Blog.index) {
    Method.get
  }

  Routing(/Route.Blog.feed) {
    Method.get
    Path {
      "feed"
      "atom.xml"
    }
  }

  Routing(/Route.Blog.show) {
    Method.get
    Path {
      "posts"
      blogSlugOrId
    }
  }
}

private let collectionsRouter = OneOf {
  Routing(/Route.Collections.index) {
    Method.get
  }

  OneOf {
    Routing(/Route.Collections.show) {
      Method.get
      Path { String.parser().pipe { Episode.Collection.Slug.parser() } }
    }

    Routing(/Route.Collections.section) {
      Method.get
      Path {
        String.parser().pipe { Episode.Collection.Slug.parser() }
        String.parser().pipe { Episode.Collection.Section.Slug.parser() }
      }
    }

    Routing(/Route.Collections.episode) {
      Method.get
      Path {
        String.parser().pipe { Episode.Collection.Slug.parser() }
        String.parser().pipe { Episode.Collection.Section.Slug.parser() }
        OneOf {
          String.parser().pipe(/Either<String, Episode.Id>.left)
          Int.parser().pipe { Episode.Id.parser() }.pipe(/Either<String, Episode.Id>.right)
        }
      }
    }
  }
}

private let episodeSlugOrId = OneOf {
  String.parser(of: Substring.self)
    .pipe(/Either<String, Episode.Id>.left)

  Int.parser(of: Substring.self)
    .pipe { Episode.Id.parser() }
    .pipe(/Either<String, Episode.Id>.right)
}

private let episodeRouter = OneOf {
  Routing(/Route.EpisodeRoute.index) {
    Method.get
  }

  Routing(/Route.EpisodeRoute.show) {
    Method.get
    Path { episodeSlugOrId }
  }

  Routing(/Route.EpisodeRoute.progress) {
    Method.post
    Path {
      episodeSlugOrId
      "progress"
    }
    Query {
      Field("percent", Int.parser())
    }
  }
}

private let enterpriseRouter = OneOf {
  Routing(/Route.Enterprise.landing) {
    Method.get
    Path { String.parser().pipe { EnterpriseAccount.Domain.parser() } }
  }

  Routing(/Route.Enterprise.requestInvite) {
    Method.post
    Path {
      String.parser().pipe { EnterpriseAccount.Domain.parser() }
      "request"
    }
    Body {
      FormCoded(EnterpriseRequestFormData.self, decoder: formDecoder)
    }
  }

  Routing(/Route.Enterprise.acceptInvite) {
    Parse {
      Method.get
      Path {
        String.parser().pipe { EnterpriseAccount.Domain.parser() }
        "accept"
      }
      Query {
        Field("email", String.parser().pipe { Encrypted<String>.parser() })
        Field("user_id", String.parser().pipe { Encrypted<String>.parser() })
      }
    }
    .pipe(
      Conversion(
        apply: { ($0, $1.0, $1.1) },
        unapply: { ($0, ($1, $2)) }
      )
    )
  }
}

private let feedRouter = OneOf {
  Routing(/Route.Feed.atom) {
    Method.get
    Path { "atom.xml" }
  }

  Routing(/Route.Feed.episodes) {
    Method.get
    Path { "episodes.xml" }
  }
}

private let inviteRouter = OneOf {
  Routing(/Route.Invite.accept) {
    Method.post
    Path {
      UUID.parser().pipe { TeamInvite.Id.parser() }
      "accept"
    }
  }

  Routing(/Route.Invite.addTeammate) {
    Method.post
    Path { "add" }
    Body {
      FormData {
        Optionally {
          Field("email", String.parser().pipe { EmailAddress.parser() })
        }
      }
    }
  }

  Routing(/Route.Invite.resend) {
    Method.post
    Path {
      UUID.parser().pipe { TeamInvite.Id.parser() }
      "resend"
    }
  }

  Routing(/Route.Invite.revoke) {
    Method.post
    Path {
      UUID.parser().pipe { TeamInvite.Id.parser() }
      "revoke"
    }
  }

  Routing(/Route.Invite.send) {
    Method.post
    Body {
      FormData {
        Optionally {
          Field("email", String.parser().pipe { EmailAddress.parser() })
        }
      }
    }
  }

  Routing(/Route.Invite.show) {
    Method.get
    Path {
      UUID.parser().pipe { TeamInvite.Id.parser() }
    }
  }
}

private let teamRouter = OneOf {
  Routing(/Route.Team.join) {
    Method.post
    Path {
      "team"
      String.parser().pipe { Subscription.TeamInviteCode.parser() }
      "join"
    }
  }

  Routing(/Route.Team.joinLanding) {
    Method.get
    Path {
      "team"
      String.parser().pipe { Subscription.TeamInviteCode.parser() }
      "join"
    }
  }

  Routing(/Route.Team.leave) {
    Method.post
    Path {
      "account"
      "team"
      "leave"
    }
  }

  Routing(/Route.Team.remove) {
    Method.post
    Path {
      "account"
      "team"
      "members"
      UUID.parser().pipe { User.Id.parser() }
      "remove"
    }
  }
}

private let webhooksRouter = Routing(/Route.Webhooks.stripe) {
  Path { "stripe" }

  OneOf {
    Routing(/Route.Webhooks._Stripe.paymentIntents) {
      Method.post
      Body {
        JSON(
          Stripe.Event<PaymentIntent>.self,
          decoder: Stripe.jsonDecoder,
          encoder: Stripe.jsonEncoder
        )
      }
    }

    Routing(/Route.Webhooks._Stripe.subscriptions) {
      Method.post
      Body {
        JSON(
          Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
          decoder: Stripe.jsonDecoder,
          encoder: Stripe.jsonEncoder
        )
      }
    }

    Routing(/Route.Webhooks._Stripe.unknown) {
      Method.post
      Body {
        JSON(
          Stripe.Event<Prelude.Unit>.self,
          decoder: Stripe.jsonDecoder,
          encoder: Stripe.jsonEncoder
        )
      }
    }

    Routing(/Route.Webhooks._Stripe.fatal) {
      Method.post
    }
  }
}

let router = OneOf {
  OneOf {
    Routing(/Route.home) {
      Method.get
    }

    Routing(/Route.about) {
      Method.get
      Path { "about" }
    }

    Routing(/Route.account) {
      Path { "account" }
      accountRouter
    }

    Routing(/Route.admin) {
      Path { "admin" }
      adminRouter
    }

    Routing(/Route.api) {
      Path { "api" }
      apiRouter
    }

    Routing(/Route.appleDeveloperMerchantIdDomainAssociation) {
      Method.get
      Path {
        ".well-known"
        "apple-developer-merchantid-domain-association"
      }
    }

    Routing(/Route.blog) {
      Path { "blog" }
      blogRouter
    }

    Routing(/Route.collections) {
      Path { "collections" }
      collectionsRouter
    }

    Routing(/Route.episode) {
      Path { "episodes" }
      episodeRouter
    }
  }

  OneOf {
    Routing(/Route.enterprise) {
      Path { "enterprise" }
      enterpriseRouter
    }

    Routing(/Route.feed) {
      Path { "feed" }
      feedRouter
    }

    Routing(/Route.gifts) {
      Path { "gifts" }
      giftsRouter
    }

    Routing(/Route.discounts) {
      Method.get
      Path {
        "discounts"
        String.parser().pipe { Stripe.Coupon.Id.parser() }
      }
      Query {
        Optionally {
          Field("billing", String.parser().pipe { Pricing.Billing.parser() })
        }
      }
    }

    Routing(/Route.endGhosting) {
      Method.post
      Path {
        "ghosting"
        "end"
      }
    }

    Routing(/Route.expressUnsubscribe) {
      Method.get
      Path {
        "newsletters"
        "express-unsubscribe"
      }
      Query {
        Field("payload", String.parser().pipe { Encrypted<String>.parser() })
      }
    }

    Routing(/Route.expressUnsubscribeReply) {
      Method.post
      Path {
        "newsletters"
        "express-unsubscribe-reply"
      }
      Body {
        FormCoded(MailgunForwardPayload.self, decoder: formDecoder)
      }
    }

    Routing(/Route.gitHubCallback) {
      Method.get
      Path { "github-auth" }
      Query {
        Optionally {
          Field("code", String.parser())
        }
        Optionally {
          Field("redirect", String.parser())
        }
      }
    }

    Routing(/Route.invite) {
      Path { "invites" }
      inviteRouter
    }
  }

  OneOf {
    Routing(/Route.login) {
      Method.get
      Path { "login" }
      Query {
        Optionally {
          Field("redirect", String.parser())
        }
      }
    }

    Routing(/Route.logout) {
      Method.get
      Path { "logout" }
    }

    Routing(/Route.pricingLanding) {
      Method.get
      Path { "pricing" }
    }

    Routing(/Route.privacy) {
      Method.get
      Path { "privacy" }
    }

    Routing(/Route.subscribe) {
      Method.post
      Path { "subscribe" }
      Optionally {
        Body {
          FormData {
            Optionally {
              Field("coupon", String.parser().pipe { Coupon.Id.parser() })
            }
            Field(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue, Bool.parser(), default: false)
            Parse {
              Field("pricing[billing]", String.parser().pipe { Pricing.Billing.parser() })
              Field("pricing[quantity]", Int.parser())
            }
            .pipe { UnsafeBitCast(Pricing.init(billing:quantity:)) }
            Optionally {
              Field(
                SubscribeData.CodingKeys.referralCode.rawValue,
                String.parser().pipe { User.ReferralCode.parser() }
              )
            }
            Many {
              Field("teammate", String.parser().pipe { EmailAddress.parser() })
            }
            Parse {
              Field("token", String.parser().pipe { Token.Id.parser() })
              Field(
                SubscribeData.CodingKeys.useRegionalDiscount.rawValue, Bool.parser(), default: false
              )
            }
          }
          .pipe(
            Conversion(
              apply: { ($0, $1, $2, $3, $4, $5.0, $5.1) },
              unapply: { ($0, $1, $2, $3, $4, ($5, $6)) }
            )
          )
          .pipe {
            UnsafeBitCast(
              SubscribeData.init(
                coupon:isOwnerTakingSeat:pricing:referralCode:teammates:token:useRegionalDiscount:
              )
            )
          }
        }
      }
    }

    Routing(/Route.subscribeConfirmation) {
      Method.get
      Parse {
        Path {
          "subscribe"
          String.parser().pipe { Pricing.Lane.parser() }
        }
        Query {
          Optionally {
            Field("billing", String.parser().pipe { Pricing.Billing.parser() })
          }
          Optionally {
            Field("isOwnerTakingSeat", Bool.parser())
          }
          Optionally {
            Field(
              "teammates",
              Many {
                Prefix { $0 != "," }
                  .pipe { String.parser() }
                  .pipe { EmailAddress.parser() }
              } separatedBy: {
                ","
              }
            )
          }
          Optionally {
            Field("ref", String.parser().pipe { User.ReferralCode.parser() })
          }
          Optionally {
            Field("useRegionalDiscount", Bool.parser())
          }
        }
      }
      .pipe(
        Conversion(
          apply: { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) },
          unapply: { ($0, ($1, $2, $3, $4, $5)) }
        )
      )
    }

    Routing(/Route.team) { teamRouter }

    Routing(/Route.useEpisodeCredit) {
      Method.post
      Path {
        "episodes"
        Int.parser().pipe { Episode.Id.parser() }
        "credit"
      }
    }

    Routing(/Route.webhooks) {
      Path { "webhooks" }
      webhooksRouter
    }
  }
}

/*
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

   .case(.collections(.index))
     <¢> get %> "collections" <% end,

   .case { .collections(.show($0)) }
     <¢> get %> "collections" %> pathParam(.tagged(.string)) <% end,

   .case { .collections(.section($0, $1)) }
     <¢> get %> "collections" %> pathParam(.tagged(.string)) <%> pathParam(.tagged(.string)) <% end,

   parenthesize(.case { .collections(.episode($0, $1, $2)) })
     <¢> get %> "collections"
     %> pathParam(.tagged(.string))
     <%> pathParam(.tagged(.string))
     <%> pathParam(.episodeIdOrString)
     <% end,

   .case(.episode(.index))
     <¢> get %> "episodes" <% end,

   parenthesize(.case { .episode(.progress(param: $0, percent: $1)) })
     <¢> post %> "episodes" %> pathParam(.episodeIdOrString) <%> "progress"
     %> queryParam("percent", .int)
     <% end,

   .case { .episode(.show($0)) }
     <¢> get %> "episodes" %> pathParam(.episodeIdOrString) <% end,

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

   .case(.feed(.atom))
     <¢> get %> "feed" %> "atom.xml" <% end,

   .case(.feed(.episodes))
     <¢> (get <|> head) %> "feed" %> "episodes.xml" <% end,

   .case(Route.gifts)
     <¢> "gifts" %> giftsRouter,

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
     <%> queryParam("useRegionalDiscount", opt(.bool))
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

   .case { .webhooks(.stripe(.paymentIntents($0))) }
     <¢> post %> "webhooks" %> "stripe"
     %> jsonBody(
       Stripe.Event<PaymentIntent>.self,
       encoder: Stripe.jsonEncoder,
       decoder: Stripe.jsonDecoder
     )
     <% end,

   .case { .webhooks(.stripe(.subscriptions($0))) }
     <¢> post %> "webhooks" %> "stripe"
     %> jsonBody(
       Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
       encoder: Stripe.jsonEncoder,
       decoder: Stripe.jsonDecoder
     )
     <% end,

   .case { .webhooks(.stripe(.unknown($0))) }
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

     let rawCouponValue = keyValues.first(where: { k, _ in k == "coupon" })?.1
     let coupon = rawCouponValue == "" ? nil : rawCouponValue.flatMap(Coupon.Id.init(rawValue:))
     let referralCode = keyValues
       .first(where: { k, _ in k == SubscribeData.CodingKeys.referralCode.rawValue })?.1
       .filter { !$0.isEmpty }
       .flatMap(User.ReferralCode.init)
     let teammates = keyValues.filter({ k, _ in k.prefix(9) == "teammates" })
       .compactMap { _, v in v }
       .map(EmailAddress.init(rawValue:))

     let useRegionalDiscount = keyValues
       .first(where: { k, _ in k == SubscribeData.CodingKeys.useRegionalDiscount.rawValue })?
       .1 == "true"

     return SubscribeData(
       coupon: coupon,
       isOwnerTakingSeat: isOwnerTakingSeat,
       pricing: Pricing(billing: billing, quantity: quantity),
       referralCode: referralCode,
       teammates: teammates,
       token: token,
       useRegionalDiscount: useRegionalDiscount
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
     if data.useRegionalDiscount {
       parts.append("\(SubscribeData.CodingKeys.useRegionalDiscount.rawValue)=\(data.useRegionalDiscount)")
     }
     return parts.joined(separator: "&")
 }
 )
 */
