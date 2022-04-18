import CasePaths
import Either
import EmailAddress
import Foundation
import Models
import PointFreePrelude
import Prelude
import Stripe
import Tagged
import UrlFormEncoding
import _URLRouting

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum SiteRoute: Equatable {
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
  Parse(.string.map(/Either<String, BlogPost.Id>.left))

  Int.parser(of: Substring.self) // FIXME?
    .map(.representing(BlogPost.Id.self).map(/Either<String, BlogPost.Id>.right))
}

private let blogRouter = OneOf {
  Route(/SiteRoute.Blog.index)

  Route(/SiteRoute.Blog.feed) {
    Path {
      "feed"
      "atom.xml"
    }
  }

  Route(/SiteRoute.Blog.show) {
    Path {
      "posts"
      blogSlugOrId
    }
  }
}

private let episodeSlugOrId = OneOf {
  Parse(.string.map(/Either<String, Episode.Id>.left))

  Int.parser(of: Substring.self) // FIXME?
    .map(.representing(Episode.Id.self).map(/Either<String, Episode.Id>.right))
}

private let collectionsRouter = OneOf {
  Route(/SiteRoute.Collections.index)

  OneOf {
    Route(/SiteRoute.Collections.show) {
      Path { Parse(.string.representing(Episode.Collection.Slug.self)) }
    }

    Route(/SiteRoute.Collections.section) {
      Path {
        Parse(.string.representing(Episode.Collection.Slug.self))
        Parse(.string.representing(Episode.Collection.Section.Slug.self))
      }
    }

    Route(/SiteRoute.Collections.episode) {
      Path {
        Parse(.string.representing(Episode.Collection.Slug.self))
        Parse(.string.representing(Episode.Collection.Section.Slug.self))
        episodeSlugOrId
      }
    }
  }
}

private let episodeRouter = OneOf {
  Route(/SiteRoute.EpisodeRoute.index)

  Route(/SiteRoute.EpisodeRoute.show) {
    Path { episodeSlugOrId }
  }

  Route(/SiteRoute.EpisodeRoute.progress) {
    Method.post
    Path {
      episodeSlugOrId
      "progress"
    }
    Query {
      Field("percent") { Int.parser() }
    }
  }
}

private let enterpriseRouter = OneOf {
  Route(/SiteRoute.Enterprise.landing) {
    Path { Parse(.string.representing(EnterpriseAccount.Domain.self)) }
  }

  Route(/SiteRoute.Enterprise.requestInvite) {
    Method.post
    Path {
      Parse(.string.representing(EnterpriseAccount.Domain.self))
      "request"
    }
    Body(.data.form(EnterpriseRequestFormData.self, decoder: formDecoder))
  }

  Route(/SiteRoute.Enterprise.acceptInvite) {
    Parse(
      .convert(
        apply: { ($0, $1.0, $1.1) },
        unapply: { ($0, ($1, $2)) }
      )
    ) {
      Path {
        Parse(.string.representing(EnterpriseAccount.Domain.self))
        "accept"
      }
      Query {
        Field("email", .string.representing(Encrypted.self))
        Field("user_id", .string.representing(Encrypted.self))
      }
    }
  }
}

private let feedRouter = OneOf {
  Route(/SiteRoute.Feed.atom) {
    Path { "atom.xml" }
  }

  Route(/SiteRoute.Feed.episodes) {
    Path { "episodes.xml" }
  }
}

private let inviteRouter = OneOf {
  Route(/SiteRoute.Invite.accept) {
    Method.post
    Path {
      UUID.parser().map(.representing(TeamInvite.Id.self))
      "accept"
    }
  }

  Route(/SiteRoute.Invite.addTeammate) {
    Method.post
    Path { "add" }
    Body {
      FormData {
        Optionally {
          Field("email", .string.representing(EmailAddress.self))
        }
      }
    }
  }

  Route(/SiteRoute.Invite.resend) {
    Method.post
    Path {
      UUID.parser().map(.representing(TeamInvite.Id.self))
      "resend"
    }
  }

  Route(/SiteRoute.Invite.revoke) {
    Method.post
    Path {
      UUID.parser().map(.representing(TeamInvite.Id.self))
      "revoke"
    }
  }

  Route(/SiteRoute.Invite.send) {
    Method.post
    Body {
      FormData {
        Optionally {
          Field("email", .string.representing(EmailAddress.self))
        }
      }
    }
  }

  Route(/SiteRoute.Invite.show) {
    Path { UUID.parser().map(.representing(TeamInvite.Id.self)) }
  }
}

private let teamRouter = OneOf {
  Route(/SiteRoute.Team.join) {
    Method.post
    Path {
      "team"
      Parse(.string.representing(Subscription.TeamInviteCode.self))
      "join"
    }
  }

  Route(/SiteRoute.Team.joinLanding) {
    Path {
      "team"
      Parse(.string.representing(Subscription.TeamInviteCode.self))
      "join"
    }
  }

  Route(/SiteRoute.Team.leave) {
    Method.post
    Path {
      "account"
      "team"
      "leave"
    }
  }

  Route(/SiteRoute.Team.remove) {
    Method.post
    Path {
      "account"
      "team"
      "members"
      UUID.parser().map(.representing(User.Id.self))
      "remove"
    }
  }
}

private let webhooksRouter = Route(/SiteRoute.Webhooks.stripe) {
  Path { "stripe" }

  OneOf {
    Route(/SiteRoute.Webhooks._Stripe.paymentIntents) {
      Method.post
      Body {
        Parse(
          .data.json(
            Stripe.Event<PaymentIntent>.self,
            decoder: Stripe.jsonDecoder,
            encoder: Stripe.jsonEncoder
          )
        )
      }
    }

    Route(/SiteRoute.Webhooks._Stripe.subscriptions) {
      Method.post
      Body {
        Parse(
          .data.json(
            Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
            decoder: Stripe.jsonDecoder,
            encoder: Stripe.jsonEncoder
          )
        )
      }
    }

    Route(/SiteRoute.Webhooks._Stripe.unknown) {
      Method.post
      Body {
        Parse(
          .data.json(
            Stripe.Event<Prelude.Unit>.self,
            decoder: Stripe.jsonDecoder,
            encoder: Stripe.jsonEncoder
          )
        )
      }
    }

    Route(/SiteRoute.Webhooks._Stripe.fatal) {
      Method.post
    }
  }
}

let router = OneOf {
  OneOf {
    Route(/SiteRoute.home)

    Route(/SiteRoute.about) {
      Path { "about" }
    }

    Route(/SiteRoute.account) {
      Path { "account" }
      accountRouter
    }

    Route(/SiteRoute.admin) {
      Path { "admin" }
      adminRouter
    }

    Route(/SiteRoute.api) {
      Path { "api" }
      apiRouter
    }

    Route(/SiteRoute.appleDeveloperMerchantIdDomainAssociation) {
      Path {
        ".well-known"
        "apple-developer-merchantid-domain-association"
      }
    }

    Route(/SiteRoute.blog) {
      Path { "blog" }
      blogRouter
    }

    Route(/SiteRoute.collections) {
      Path { "collections" }
      collectionsRouter
    }

    Route(/SiteRoute.episode) {
      Path { "episodes" }
      episodeRouter
    }
  }

  OneOf {
    Route(/SiteRoute.enterprise) {
      Path { "enterprise" }
      enterpriseRouter
    }

    Route(/SiteRoute.feed) {
      Path { "feed" }
      feedRouter
    }

    Route(/SiteRoute.gifts) {
      Path { "gifts" }
      giftsRouter
    }

    Route(/SiteRoute.discounts) {
      Path {
        "discounts"
        Parse(.string.representing(Stripe.Coupon.Id.self))
      }
      Query {
        Optionally {
          Field("billing") { Pricing.Billing.parser() }
        }
      }
    }

    Route(/SiteRoute.endGhosting) {
      Method.post
      Path {
        "ghosting"
        "end"
      }
    }

    Route(/SiteRoute.expressUnsubscribe) {
      Path {
        "newsletters"
        "express-unsubscribe"
      }
      Query {
        Field("payload", .string.representing(Encrypted.self))
      }
    }

    Route(/SiteRoute.expressUnsubscribeReply) {
      Method.post
      Path {
        "newsletters"
        "express-unsubscribe-reply"
      }
      Body(.data.form(MailgunForwardPayload.self, decoder: formDecoder))
    }

    Route(/SiteRoute.gitHubCallback) {
      Path { "github-auth" }
      Query {
        Optionally {
          Field("code", .string)
        }
        Optionally {
          Field("redirect", .string)
        }
      }
    }

    Route(/SiteRoute.invite) {
      Path { "invites" }
      inviteRouter
    }
  }

  OneOf {
    Route(/SiteRoute.login) {
      Path { "login" }
      Query {
        Optionally {
          Field("redirect", .string)
        }
      }
    }

    Route(/SiteRoute.logout) {
      Path { "logout" }
    }

    Route(/SiteRoute.pricingLanding) {
      Path { "pricing" }
    }

    Route(/SiteRoute.privacy) {
      Path { "privacy" }
    }

    Route(/SiteRoute.subscribe) {
      Method.post
      Path { "subscribe" }
      Optionally {
        Body {
          FormData {
            Optionally {
              Field("coupon", .string.representing(Coupon.Id.self))
            }
            Field(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue, default: false) {
              Bool.parser()
            }
            Parse(.memberwise(Pricing.init(billing:quantity:))) {
              Field("pricing[billing]") { Pricing.Billing.parser() }
              Field("pricing[quantity]") { Int.parser() }
            }
            Optionally {
              Field(
                SubscribeData.CodingKeys.referralCode.rawValue,
                .string.representing(User.ReferralCode.self)
              )
            }
            Many {
              Field("teammate", .string.representing(EmailAddress.self))
            }
            Parse {
              Field("token", .string.representing(Token.Id.self))
              Field(SubscribeData.CodingKeys.useRegionalDiscount.rawValue, default: false) {
                Bool.parser()
              }
            }
          }
        }
        .map(
          .convert(
            apply: { ($0, $1, $2, $3, $4, $5.0, $5.1) },
            unapply: { ($0, $1, $2, $3, $4, ($5, $6)) }
          )
          .map(
            .memberwise(
              SubscribeData.init(
                coupon:isOwnerTakingSeat:pricing:referralCode:teammates:token:useRegionalDiscount:
              )
            )
          )
        )
      }
    }

    Route(/SiteRoute.subscribeConfirmation) {
      Parse(
        .convert(
          apply: { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) },
          unapply: { ($0, ($1, $2, $3, $4, $5)) }
        )
      ) {
        Path {
          "subscribe"
          Pricing.Lane.parser()
        }
        Query {
          Optionally {
            Field("billing") { Pricing.Billing.parser() }
          }
          Optionally {
            Field("isOwnerTakingSeat") { Bool.parser() }
          }
          Optionally {
            Field("teammates") {
              Many {
                Prefix { $0 != "," }.map(.string.representing(EmailAddress.self))
              } separator: {
                ","
              }
            }
          }
          Optionally {
            Field("ref", .string.representing(User.ReferralCode.self))
          }
          Optionally {
            Field("useRegionalDiscount") { Bool.parser() }
          }
        }
      }
    }

    Route(/SiteRoute.team) { teamRouter }

    Route(/SiteRoute.useEpisodeCredit) {
      Method.post
      Path {
        "episodes"
        Int.parser().map(.representing(Episode.Id.self))
        "credit"
      }
    }

    Route(/SiteRoute.webhooks) {
      Path { "webhooks" }
      webhooksRouter
    }
  }
}
