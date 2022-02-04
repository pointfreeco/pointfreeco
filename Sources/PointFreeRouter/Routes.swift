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
import _URLRouting

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum AppRoute: Equatable {
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
  Convert(.string.map(/Either<String, BlogPost.Id>.left))

  Int.parser(of: Substring.self) // FIXME
    .map(.rawRepresentable(as: BlogPost.Id.self).map(/Either<String, BlogPost.Id>.right))
}

private let blogRouter = OneOf {
  Route(/AppRoute.Blog.index) {
    Method.get
  }

  Route(/AppRoute.Blog.feed) {
    Method.get
    Path {
      "feed"
      "atom.xml"
    }
  }

  Route(/AppRoute.Blog.show) {
    Method.get
    Path {
      "posts"
      blogSlugOrId
    }
  }
}

private let episodeSlugOrId = OneOf {
  Convert(.string.map(/Either<String, Episode.Id>.left))

  Int.parser(of: Substring.self) // FIXME
    .map(.rawRepresentable(as: Episode.Id.self).map(/Either<String, Episode.Id>.right))
}

private let collectionsRouter = OneOf {
  Route(/AppRoute.Collections.index) {
    Method.get
  }

  OneOf {
    Route(/AppRoute.Collections.show) {
      Method.get
      Path { Convert(.string.rawRepresentable(as: Episode.Collection.Slug.self)) }
    }

    Route(/AppRoute.Collections.section) {
      Method.get
      Path {
        Convert(.string.rawRepresentable(as: Episode.Collection.Slug.self))
        Convert(.string.rawRepresentable(as: Episode.Collection.Section.Slug.self))
      }
    }

    Route(/AppRoute.Collections.episode) {
      Method.get
      Path {
        Convert(.string.rawRepresentable(as: Episode.Collection.Slug.self))
        Convert(.string.rawRepresentable(as: Episode.Collection.Section.Slug.self))
        episodeSlugOrId
      }
    }
  }
}

private let episodeRouter = OneOf {
  Route(/AppRoute.EpisodeRoute.index) {
    Method.get
  }

  Route(/AppRoute.EpisodeRoute.show) {
    Method.get
    Path { episodeSlugOrId }
  }

  Route(/AppRoute.EpisodeRoute.progress) {
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
  Route(/AppRoute.Enterprise.landing) {
    Method.get
    Path { Convert(.string.rawRepresentable(as: EnterpriseAccount.Domain.self)) }
  }

  Route(/AppRoute.Enterprise.requestInvite) {
    Method.post
    Path {
      Convert(.string.rawRepresentable(as: EnterpriseAccount.Domain.self))
      "request"
    }
    Body {
      FormCoded(EnterpriseRequestFormData.self, decoder: formDecoder)
    }
  }

  Route(/AppRoute.Enterprise.acceptInvite) {
    Parse {
      Method.get
      Path {
        Convert(.string.rawRepresentable(as: EnterpriseAccount.Domain.self))
        "accept"
      }
      Query {
        Field("email", Convert(.string.rawRepresentable(as: Encrypted.self)))
        Field("user_id", Convert(.string.rawRepresentable(as: Encrypted.self)))
      }
    }
    .map(
      AnyConversion(
        apply: { ($0, $1.0, $1.1) },
        unapply: { ($0, ($1, $2)) }
      )
    )
  }
}

private let feedRouter = OneOf {
  Route(/AppRoute.Feed.atom) {
    Method.get
    Path { "atom.xml" }
  }

  Route(/AppRoute.Feed.episodes) {
    Method.get
    Path { "episodes.xml" }
  }
}

private let inviteRouter = OneOf {
  Route(/AppRoute.Invite.accept) {
    Method.post
    Path {
      UUID.parser().map(.rawRepresentable(as: TeamInvite.Id.self))
      "accept"
    }
  }

  Route(/AppRoute.Invite.addTeammate) {
    Method.post
    Path { "add" }
    Body {
      FormData {
        Optionally {
          Field("email", Convert(.string.rawRepresentable(as: EmailAddress.self)))
        }
      }
    }
  }

  Route(/AppRoute.Invite.resend) {
    Method.post
    Path {
      UUID.parser().map(.rawRepresentable(as: TeamInvite.Id.self))
      "resend"
    }
  }

  Route(/AppRoute.Invite.revoke) {
    Method.post
    Path {
      UUID.parser().map(.rawRepresentable(as: TeamInvite.Id.self))
      "revoke"
    }
  }

  Route(/AppRoute.Invite.send) {
    Method.post
    Body {
      FormData {
        Optionally {
          Field("email", Convert(.string.rawRepresentable(as: EmailAddress.self)))
        }
      }
    }
  }

  Route(/AppRoute.Invite.show) {
    Method.get
    Path { UUID.parser().map(.rawRepresentable(as: TeamInvite.Id.self)) }
  }
}

private let teamRouter = OneOf {
  Route(/AppRoute.Team.join) {
    Method.post
    Path {
      "team"
      Convert(.string.rawRepresentable(as: Subscription.TeamInviteCode.self))
      "join"
    }
  }

  Route(/AppRoute.Team.joinLanding) {
    Method.get
    Path {
      "team"
      Convert(.string.rawRepresentable(as: Subscription.TeamInviteCode.self))
      "join"
    }
  }

  Route(/AppRoute.Team.leave) {
    Method.post
    Path {
      "account"
      "team"
      "leave"
    }
  }

  Route(/AppRoute.Team.remove) {
    Method.post
    Path {
      "account"
      "team"
      "members"
      UUID.parser().map(.rawRepresentable(as: User.Id.self))
      "remove"
    }
  }
}

private let webhooksRouter = Route(/AppRoute.Webhooks.stripe) {
  Path { "stripe" }

  OneOf {
    Route(/AppRoute.Webhooks._Stripe.paymentIntents) {
      Method.post
      Body {
        Convert(
          .data.json(
            Stripe.Event<PaymentIntent>.self,
            decoder: Stripe.jsonDecoder,
            encoder: Stripe.jsonEncoder
          )
        )
      }
    }

    Route(/AppRoute.Webhooks._Stripe.subscriptions) {
      Method.post
      Body {
        Convert(
          .data.json(
            Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
            decoder: Stripe.jsonDecoder,
            encoder: Stripe.jsonEncoder
          )
        )
      }
    }

    Route(/AppRoute.Webhooks._Stripe.unknown) {
      Method.post
      Body {
        Convert(
          .data.json(
            Stripe.Event<Prelude.Unit>.self,
            decoder: Stripe.jsonDecoder,
            encoder: Stripe.jsonEncoder
          )
        )
      }
    }

    Route(/AppRoute.Webhooks._Stripe.fatal) {
      Method.post
    }
  }
}

let router = OneOf {
  OneOf {
    Route(/AppRoute.home)

    Route(/AppRoute.about) {
      Path { "about" }
    }

    Route(/AppRoute.account) {
      Path { "account" }
      accountRouter
    }

    Route(/AppRoute.admin) {
      Path { "admin" }
      adminRouter
    }

    Route(/AppRoute.api) {
      Path { "api" }
      apiRouter
    }

    Route(/AppRoute.appleDeveloperMerchantIdDomainAssociation) {
      Path {
        ".well-known"
        "apple-developer-merchantid-domain-association"
      }
    }

    Route(/AppRoute.blog) {
      Path { "blog" }
      blogRouter
    }

    Route(/AppRoute.collections) {
      Path { "collections" }
      collectionsRouter
    }

    Route(/AppRoute.episode) {
      Path { "episodes" }
      episodeRouter
    }
  }

  OneOf {
    Route(/AppRoute.enterprise) {
      Path { "enterprise" }
      enterpriseRouter
    }

    Route(/AppRoute.feed) {
      Path { "feed" }
      feedRouter
    }

    Route(/AppRoute.gifts) {
      Path { "gifts" }
      giftsRouter
    }

    Route(/AppRoute.discounts) {
      Path {
        "discounts"
        Convert(.string.rawRepresentable(as: Stripe.Coupon.Id.self))
      }
      Query {
        Optionally {
          Field("billing", Convert(.string.rawRepresentable(as: Pricing.Billing.self)))
        }
      }
    }

    Route(/AppRoute.endGhosting) {
      Method.post
      Path {
        "ghosting"
        "end"
      }
    }

    Route(/AppRoute.expressUnsubscribe) {
      Path {
        "newsletters"
        "express-unsubscribe"
      }
      Query {
        Field("payload", Convert(.string.rawRepresentable(as: Encrypted.self)))
      }
    }

    Route(/AppRoute.expressUnsubscribeReply) {
      Method.post
      Path {
        "newsletters"
        "express-unsubscribe-reply"
      }
      Body {
        FormCoded(MailgunForwardPayload.self, decoder: formDecoder)
      }
    }

    Route(/AppRoute.gitHubCallback) {
      Path { "github-auth" }
      Query {
        Optionally {
          Field("code", Convert(.string))
        }
        Optionally {
          Field("redirect", Convert(.string))
        }
      }
    }

    Route(/AppRoute.invite) {
      Path { "invites" }
      inviteRouter
    }
  }

  OneOf {
    Route(/AppRoute.login) {
      Path { "login" }
      Query {
        Optionally {
          Field("redirect", Convert(.string))
        }
      }
    }

    Route(/AppRoute.logout) {
      Path { "logout" }
    }

    Route(/AppRoute.pricingLanding) {
      Path { "pricing" }
    }

    Route(/AppRoute.privacy) {
      Path { "privacy" }
    }

    Route(/AppRoute.subscribe) {
      Method.post
      Path { "subscribe" }
      Optionally {
        Body {
          FormData {
            Optionally {
              Field("coupon", Convert(.string.rawRepresentable(as: Coupon.Id.self)))
            }
            Field(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue, Bool.parser(), default: false)
            Parse {
              Field("pricing[billing]", Convert(.string.rawRepresentable(as: Pricing.Billing.self)))
              Field("pricing[quantity]", Int.parser())
            }
            .map(.destructure(Pricing.init(billing:quantity:)))
            Optionally {
              Field(
                SubscribeData.CodingKeys.referralCode.rawValue,
                Convert(.string.rawRepresentable(as: User.ReferralCode.self))
              )
            }
            Many {
              Field("teammate", Convert(.string.rawRepresentable(as: EmailAddress.self)))
            }
            Parse {
              Field("token", Convert(.string.rawRepresentable(as: Token.Id.self)))
              Field(
                SubscribeData.CodingKeys.useRegionalDiscount.rawValue, Bool.parser(), default: false
              )
            }
          }
          .map(
            AnyConversion(
              apply: { ($0, $1, $2, $3, $4, $5.0, $5.1) },
              unapply: { ($0, $1, $2, $3, $4, ($5, $6)) }
            )
          )
          .map(
            .destructure(
              SubscribeData.init(
                coupon:isOwnerTakingSeat:pricing:referralCode:teammates:token:useRegionalDiscount:
              )
            )
          )
        }
      }
    }

    Route(/AppRoute.subscribeConfirmation) {
      Parse {
        Path {
          "subscribe"
          Convert(.string.rawRepresentable(as: Pricing.Lane.self))
        }
        Query {
          Optionally {
            Field("billing", Convert(.string.rawRepresentable(as: Pricing.Billing.self)))
          }
          Optionally {
            Field("isOwnerTakingSeat", Bool.parser())
          }
          Optionally {
            Field(
              "teammates",
              Many {
                Prefix { $0 != "," }.map(.string.rawRepresentable(as: EmailAddress.self))
              } separator: {
                ","
              }
            )
          }
          Optionally {
            Field("ref", Convert(.string.rawRepresentable(as: User.ReferralCode.self)))
          }
          Optionally {
            Field("useRegionalDiscount", Bool.parser())
          }
        }
      }
      .map(
        AnyConversion(
          apply: { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) },
          unapply: { ($0, ($1, $2, $3, $4, $5)) }
        )
      )
    }

    Route(/AppRoute.team) { teamRouter }

    Route(/AppRoute.useEpisodeCredit) {
      Method.post
      Path {
        "episodes"
        Int.parser().map(.rawRepresentable(as: Episode.Id.self))
        "credit"
      }
    }

    Route(/AppRoute.webhooks) {
      Path { "webhooks" }
      webhooksRouter
    }
  }
}
