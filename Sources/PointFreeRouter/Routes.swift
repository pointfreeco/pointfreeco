import Either
import EmailAddress
import Foundation
import Models
import Prelude
import Stripe
import Tagged
import UrlFormEncoding
import URLRouting

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum SiteRoute: Equatable {
  case about
  case account(Account = .index)
  case admin(Admin = .index)
  case api(Api)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog = .index)
  case collections(Collections = .index)
  case discounts(code: Stripe.Coupon.Id, Pricing.Billing?)
  case gifts(Gifts = .index)
  case endGhosting
  case enterprise(EnterpriseAccount.Domain, Enterprise = .landing)
  case episode(EpisodeRoute = .index)
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
  case subscribe(SubscribeData? = nil)
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

    public static func show(slug: String) -> Blog { .show(.left(slug)) }
    public static func show(id: BlogPost.Id) -> Blog { .show(.right(id)) }
  }

  public enum Collections: Equatable {
    case index
    case collection(Episode.Collection.Slug, Collection = .show)

    public enum Collection: Equatable {
      case show
      case section(Episode.Collection.Section.Slug, Section = .show)
    }

    public enum Section: Equatable {
      case show
      case episode(Either<String, Episode.Id>)
    }
  }

  public enum Enterprise: Equatable {
    case acceptInvite(email: Encrypted<String>, userId: Encrypted<String>)
    case landing
    case requestInvite(EnterpriseRequestFormData)
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
    case addTeammate(EmailAddress?)
    case invitation(TeamInvite.Id, Invitation = .show)
    case send(EmailAddress?)

    public enum Invitation: Equatable {
      case accept
      case resend
      case revoke
      case show
    }
  }

  public enum Team: Equatable {
    case join(Models.Subscription.TeamInviteCode, Join = .landing)
    case leave
    case remove(User.Id)

    public enum Join: Equatable {
      case confirm
      case landing
    }
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
  Parse(.string.map(.case(Either<String, BlogPost.Id>.left)))

  Int.parser(of: Substring.self)
    .map(.representing(BlogPost.Id.self).map(.case(Either<String, BlogPost.Id>.right)))
}

private let blogRouter = OneOf {
  Route(.case(SiteRoute.Blog.index))

  Route(.case(SiteRoute.Blog.feed)) {
    Path {
      "feed"
      "atom.xml"
    }
  }

  Route(.case(SiteRoute.Blog.show)) {
    Path {
      "posts"
      blogSlugOrId
    }
  }
}

private let episodeSlugOrId = OneOf {
  Parse(.string.map(.case(Either<String, Episode.Id>.left)))

  Int.parser(of: Substring.self)
    .map(.representing(Episode.Id.self).map(.case(Either<String, Episode.Id>.right)))
}

private let collectionsRouter = OneOf {
  Route(.case(SiteRoute.Collections.index))

  Route(.case(SiteRoute.Collections.collection)) {
    Path { Parse(.string.representing(Episode.Collection.Slug.self)) }

    OneOf {
      Route(.case(SiteRoute.Collections.Collection.show))

      Route(.case(SiteRoute.Collections.Collection.section)) {
        Path { Parse(.string.representing(Episode.Collection.Section.Slug.self)) }

        OneOf {
          Route(.case(SiteRoute.Collections.Section.show))

          Route(.case(SiteRoute.Collections.Section.episode)) {
            Path { episodeSlugOrId }
          }
        }
      }
    }
  }
}

private let episodeRouter = OneOf {
  Route(.case(SiteRoute.EpisodeRoute.index))

  Route(.case(SiteRoute.EpisodeRoute.show)) {
    Path { episodeSlugOrId }
  }

  Route(.case(SiteRoute.EpisodeRoute.progress)) {
    Method.post
    Path {
      episodeSlugOrId
      "progress"
    }
    Query {
      Field("percent") { Digits() }
    }
  }
}

private let enterpriseRouter = OneOf {
  Route(.case(SiteRoute.Enterprise.landing))

  Route(.case(SiteRoute.Enterprise.requestInvite)) {
    Method.post
    Path { "request" }
    Body(.form(EnterpriseRequestFormData.self, decoder: formDecoder))
  }

  Route(.case(SiteRoute.Enterprise.acceptInvite)) {
    Path { "accept" }
    Query {
      Field("email", .string.representing(Encrypted.self))
      Field("user_id", .string.representing(Encrypted.self))
    }
  }
}

private let feedRouter = OneOf {
  Route(.case(SiteRoute.Feed.atom)) {
    Path { "atom.xml" }
  }

  Route(.case(SiteRoute.Feed.episodes)) {
    Path { "episodes.xml" }
  }
}

private let inviteRouter = OneOf {
  Route(.case(SiteRoute.Invite.addTeammate)) {
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

  Route(.case(SiteRoute.Invite.invitation)) {
    Path { UUID.parser().map(.representing(TeamInvite.Id.self)) }

    OneOf {
      Route(.case(SiteRoute.Invite.Invitation.show))

      Route(.case(SiteRoute.Invite.Invitation.accept)) {
        Method.post
        Path { "accept" }
      }

      Route(.case(SiteRoute.Invite.Invitation.resend)) {
        Method.post
        Path { "resend" }
      }

      Route(.case(SiteRoute.Invite.Invitation.revoke)) {
        Method.post
        Path { "revoke" }
      }
    }
  }

  Route(.case(SiteRoute.Invite.send)) {
    Method.post
    Body {
      FormData {
        Optionally {
          Field("email", .string.representing(EmailAddress.self))
        }
      }
    }
  }
}

private let teamRouter = OneOf {
  Route(.case(SiteRoute.Team.join)) {
    Path {
      "team"
      Parse(.string.representing(Subscription.TeamInviteCode.self))
      "join"
    }

    OneOf {
      Route(.case(SiteRoute.Team.Join.landing))

      Route(.case(SiteRoute.Team.Join.confirm)) {
        Method.post
      }
    }
  }

  Parse {
    Path {
      "account"
      "team"
    }

    OneOf {
      Route(.case(SiteRoute.Team.leave)) {
        Method.post
        Path { "leave" }
      }

      Route(.case(SiteRoute.Team.remove)) {
        Method.post
        Path {
          "members"
          UUID.parser().map(.representing(User.Id.self))
          "remove"
        }
      }
    }
  }
}

private let webhooksRouter = Route(.case(SiteRoute.Webhooks.stripe)) {
  Method.post
  Path { "stripe" }

  OneOf {
    Route(.case(SiteRoute.Webhooks._Stripe.paymentIntents)) {
      Body(
        .json(
          Stripe.Event<PaymentIntent>.self,
          decoder: Stripe.jsonDecoder,
          encoder: Stripe.jsonEncoder
        )
      )
    }

    Route(.case(SiteRoute.Webhooks._Stripe.subscriptions)) {
      Body(
        .json(
          Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
          decoder: Stripe.jsonDecoder,
          encoder: Stripe.jsonEncoder
        )
      )
    }

    Route(.case(SiteRoute.Webhooks._Stripe.unknown)) {
      Body(
        .json(
          Stripe.Event<Prelude.Unit>.self,
          decoder: Stripe.jsonDecoder,
          encoder: Stripe.jsonEncoder
        )
      )
    }
  }
  .replaceError(with: .fatal)
}

let router = OneOf {
  OneOf {
    Route(.case(SiteRoute.home))

    Route(.case(SiteRoute.about)) {
      Path { "about" }
    }

    Route(.case(SiteRoute.account)) {
      Path { "account" }
      accountRouter
    }

    Route(.case(SiteRoute.admin)) {
      Path { "admin" }
      adminRouter
    }

    Route(.case(SiteRoute.api)) {
      Path { "api" }
      apiRouter
    }

    Route(.case(SiteRoute.appleDeveloperMerchantIdDomainAssociation)) {
      Path { ".well-known"; "apple-developer-merchantid-domain-association" }
    }

    Route(.case(SiteRoute.blog)) {
      Path { "blog" }
      blogRouter
    }

    Route(.case(SiteRoute.collections)) {
      Path { "collections" }
      collectionsRouter
    }

    Route(.case(SiteRoute.episode)) {
      Path { "episodes" }
      episodeRouter
    }

    Route(.case(SiteRoute.enterprise)) {
      Path {
        "enterprise"
        Parse(.string.representing(EnterpriseAccount.Domain.self))
      }
      enterpriseRouter
    }
  }

  OneOf {
    Route(.case(SiteRoute.feed)) {
      Path { "feed" }
      feedRouter
    }

    Route(.case(SiteRoute.gifts)) {
      Path { "gifts" }
      giftsRouter
    }

    Route(.case(SiteRoute.discounts)) {
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

    Route(.case(SiteRoute.endGhosting)) {
      Method.post
      Path { "ghosting"; "end" }
    }

    Parse {
      Path { "newsletters" }

      OneOf {
        Route(.case(SiteRoute.expressUnsubscribe)) {
          Path { "express-unsubscribe" }
          Query {
            Field("payload", .string.representing(Encrypted.self))
          }
        }

        Route(.case(SiteRoute.expressUnsubscribeReply)) {
          Method.post
          Path { "express-unsubscribe-reply" }
          Body(.form(MailgunForwardPayload.self, decoder: formDecoder))
        }
      }
    }

    Route(.case(SiteRoute.gitHubCallback)) {
      Path { "github-auth" }
      Query {
        Optionally {
          Field("code")
        }
        Optionally {
          Field("redirect")
        }
      }
    }

    Route(.case(SiteRoute.invite)) {
      Path { "invites" }
      inviteRouter
    }

    Route(.case(SiteRoute.login)) {
      Path { "login" }
      Query {
        Optionally {
          Field("redirect")
        }
      }
    }

    Route(.case(SiteRoute.logout)) {
      Path { "logout" }
    }

    Route(.case(SiteRoute.pricingLanding)) {
      Path { "pricing" }
    }
  }

  OneOf {
    Route(.case(SiteRoute.privacy)) {
      Path { "privacy" }
    }

    Route(.case(SiteRoute.subscribe)) {
      Method.post
      Path { "subscribe" }
      Body {
        Optionally {
          FormData {
            Optionally {
              Field("coupon", .string.representing(Coupon.Id.self))
            }
            Field(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue, default: false) {
              Bool.parser()
            }
            Parse(.memberwise(Pricing.init(billing:quantity:))) {
              Field("pricing[billing]") { Pricing.Billing.parser() }
              Field("pricing[quantity]") { Digits() }
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
    }

    Route(.case(SiteRoute.subscribeConfirmation)) {
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

    Route(.case(SiteRoute.team)) { teamRouter }

    Route(.case(SiteRoute.useEpisodeCredit)) {
      Method.post
      Path {
        "episodes"
        Digits().map(.representing(Episode.Id.self))
        "credit"
      }
    }

    Route(.case(SiteRoute.webhooks)) {
      Path { "webhooks" }
      webhooksRouter
    }
  }
}
