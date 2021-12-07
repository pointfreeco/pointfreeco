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
  String.parser(of: Substring.self).pipe(/Either<String, BlogPost.Id>.left)

  BlogPost.Id.parser(rawValue: Int.parser()).pipe(/Either<String, BlogPost.Id>.right)
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

private let episodeSlugOrId = OneOf {
  String.parser(of: Substring.self).pipe(/Either<String, Episode.Id>.left)

  Episode.Id.parser(rawValue: Int.parser()).pipe(/Either<String, Episode.Id>.right)
}

private let collectionsRouter = OneOf {
  Routing(/Route.Collections.index) {
    Method.get
  }

  OneOf {
    Routing(/Route.Collections.show) {
      Method.get
      Path { Episode.Collection.Slug.parser(rawValue: String.parser()) }
    }

    Routing(/Route.Collections.section) {
      Method.get
      Path {
        Episode.Collection.Slug.parser(rawValue: String.parser())
        Episode.Collection.Section.Slug.parser(rawValue: String.parser())
      }
    }

    Routing(/Route.Collections.episode) {
      Method.get
      Path {
        Episode.Collection.Slug.parser(rawValue: String.parser())
        Episode.Collection.Section.Slug.parser(rawValue: String.parser())
        episodeSlugOrId
      }
    }
  }
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
    Path { EnterpriseAccount.Domain.parser(rawValue: String.parser()) }
  }

  Routing(/Route.Enterprise.requestInvite) {
    Method.post
    Path {
      EnterpriseAccount.Domain.parser(rawValue: String.parser())
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
        EnterpriseAccount.Domain.parser(rawValue: String.parser())
        "accept"
      }
      Query {
        Field("email", Encrypted.parser(rawValue: String.parser()))
        Field("user_id", Encrypted.parser(rawValue: String.parser()))
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
      TeamInvite.Id.parser(rawValue: UUID.parser())
      "accept"
    }
  }

  Routing(/Route.Invite.addTeammate) {
    Method.post
    Path { "add" }
    Body {
      FormData {
        Optionally {
          Field("email", EmailAddress.parser(rawValue: String.parser()))
        }
      }
    }
  }

  Routing(/Route.Invite.resend) {
    Method.post
    Path {
      TeamInvite.Id.parser(rawValue: UUID.parser())
      "resend"
    }
  }

  Routing(/Route.Invite.revoke) {
    Method.post
    Path {
      TeamInvite.Id.parser(rawValue: UUID.parser())
      "revoke"
    }
  }

  Routing(/Route.Invite.send) {
    Method.post
    Body {
      FormData {
        Optionally {
          Field("email", EmailAddress.parser(rawValue: String.parser()))
        }
      }
    }
  }

  Routing(/Route.Invite.show) {
    Method.get
    Path { TeamInvite.Id.parser(rawValue: UUID.parser()) }
  }
}

private let teamRouter = OneOf {
  Routing(/Route.Team.join) {
    Method.post
    Path {
      "team"
      Subscription.TeamInviteCode.parser(rawValue: String.parser())
      "join"
    }
  }

  Routing(/Route.Team.joinLanding) {
    Method.get
    Path {
      "team"
      Subscription.TeamInviteCode.parser(rawValue: String.parser())
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
      User.Id.parser(rawValue: UUID.parser())
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
          from: ArraySlice<UInt8>.self,
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
          from: ArraySlice<UInt8>.self,
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
          from: ArraySlice<UInt8>.self,
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
        Stripe.Coupon.Id.parser(rawValue: String.parser())
      }
      Query {
        Optionally {
          Field("billing", Pricing.Billing.parser(rawValue: String.parser()))
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
        Field("payload", Encrypted.parser(rawValue: String.parser()))
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
              Field("coupon", Coupon.Id.parser(rawValue: String.parser()))
            }
            Field(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue, Bool.parser(), default: false)
            Parse {
              Field("pricing[billing]", Pricing.Billing.parser(rawValue: String.parser()))
              Field("pricing[quantity]", Int.parser())
            }
            .pipe { UnsafeBitCast(Pricing.init(billing:quantity:)) }
            Optionally {
              Field(
                SubscribeData.CodingKeys.referralCode.rawValue,
                User.ReferralCode.parser(rawValue: String.parser())
              )
            }
            Many {
              Field("teammate", EmailAddress.parser(rawValue: String.parser()))
            }
            Parse {
              Field("token", Token.Id.parser(rawValue: String.parser()))
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
          Pricing.Lane.parser(rawValue: String.parser())
        }
        Query {
          Optionally {
            Field("billing", Pricing.Billing.parser(rawValue: String.parser()))
          }
          Optionally {
            Field("isOwnerTakingSeat", Bool.parser())
          }
          Optionally {
            Field(
              "teammates",
              Many {
                Prefix { $0 != "," }.pipe { EmailAddress.parser(rawValue: String.parser()) }
              } separatedBy: {
                ","
              }
            )
          }
          Optionally {
            Field("ref", User.ReferralCode.parser(rawValue: String.parser()))
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
        Episode.Id.parser(rawValue: Int.parser())
        "credit"
      }
    }

    Routing(/Route.webhooks) {
      Path { "webhooks" }
      webhooksRouter
    }
  }
}
