import Either
import EmailAddress
import Foundation
import Models
import Prelude
import Stripe
import Tagged
import URLRouting
import UrlFormEncoding

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

public enum SiteRoute: Equatable {
  case about
  case account(Account = .index)
  case admin(Admin = .index)
  case api(Api)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog = .index)
  case clips(ClipsRoute)
  case collections(Collections = .index)
  case discounts(code: Stripe.Coupon.ID, Pricing.Billing?)
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
  case live(Live)
  case login(redirect: String?)
  case logout
  case pricingLanding
  case privacy
  case resume
  case robots
  case slackInvite
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
  case teamInviteCode(TeamInviteCode)
  case useEpisodeCredit(Episode.ID)
  case webhooks(Webhooks)

  public enum Blog: Equatable {
    case feed
    case index
    case show(Either<String, BlogPost.ID>)

    public static func show(slug: String) -> Blog { .show(.left(slug)) }
    public static func show(id: BlogPost.ID) -> Blog { .show(.right(id)) }
  }

  public enum Collections: Equatable {
    case index
    case collection(Episode.Collection.Slug, Collection = .show)

    public enum Collection: Equatable {
      case show
      case section(Episode.Collection.Section.Slug, Section = .show)
    }

    public enum Section: Equatable {
      case episode(Either<String, Episode.ID>)
      case progress(param: Either<String, Episode.ID>, percent: Int)
      case show
    }
  }

  public enum Enterprise: Equatable {
    case acceptInvite(email: Encrypted<String>, userId: Encrypted<String>)
    case landing
    case requestInvite(EnterpriseRequestFormData)
  }

  public enum EpisodeRoute: Equatable {
    case index
    case progress(param: Either<String, Episode.ID>, percent: Int)
    case show(Either<String, Episode.ID>)
  }

  public enum Feed: Equatable {
    case atom
    case episodes
    case slack
  }

  public enum Invite: Equatable {
    case addTeammate(EmailAddress?)
    case invitation(TeamInvite.ID, Invitation = .show)
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
    case remove(User.ID)

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

struct SlugOrID<ID: RawRepresentable>: ParserPrinter where ID.RawValue == Int {
  var body: some ParserPrinter<Substring, Either<String, ID>> {
    OneOf {
      Parse(.string.map(.case(Either<String, ID>.left)))
      Digits().map(.representing(ID.self).map(.case(Either<String, ID>.right)))
    }
  }
}

struct BlogRouter: ParserPrinter {
  var body: some Router<SiteRoute.Blog> {
    OneOf {
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
          SlugOrID<BlogPost.ID>()
        }
      }
    }
  }
}

struct CollectionsRouter: ParserPrinter {
  var body: some Router<SiteRoute.Collections> {
    OneOf {
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
                Path { SlugOrID<Episode.ID>() }
              }
              Route(.case(SiteRoute.Collections.Section.progress(param:percent:))) {
                Method.post
                Path {
                  SlugOrID<Episode.ID>()
                  "progress"
                }
                Query { Field("percent") { Digits() } }
              }
            }
          }
        }
      }
    }
  }
}

struct EpisodeRouter: ParserPrinter {
  var body: some Router<SiteRoute.EpisodeRoute> {
    OneOf {
      Route(.case(SiteRoute.EpisodeRoute.index))

      Route(.case(SiteRoute.EpisodeRoute.show)) {
        Path { SlugOrID<Episode.ID>() }
      }

      Route(.case(SiteRoute.EpisodeRoute.progress)) {
        Method.post
        Path {
          SlugOrID<Episode.ID>()
          "progress"
        }
        Query {
          Field("percent") { Digits() }
        }
      }
    }
  }
}

struct EnterpriseRouter: ParserPrinter {
  var body: some Router<SiteRoute.Enterprise> {
    OneOf {
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
  }
}

struct FeedRouter: ParserPrinter {
  var body: some Router<SiteRoute.Feed> {
    OneOf {
      Route(.case(SiteRoute.Feed.atom)) {
        Path { "atom.xml" }
      }

      Route(.case(SiteRoute.Feed.episodes)) {
        Path { "episodes.xml" }
      }

      Route(.case(SiteRoute.Feed.slack)) {
        Path { "slack.xml" }
      }
    }
  }
}

struct InviteRouter: ParserPrinter {
  var body: some Router<SiteRoute.Invite> {
    OneOf {
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
        Path { UUID.parser().map(.representing(TeamInvite.ID.self)) }

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
  }
}

struct TeamRouter: ParserPrinter {
  var body: some Router<SiteRoute.Team> {
    OneOf {
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
              UUID.parser().map(.representing(User.ID.self))
              "remove"
            }
          }
        }
      }
    }
  }
}

struct WebhooksRouter: ParserPrinter {
  var body: some Router<SiteRoute.Webhooks> {
    Route(.case(SiteRoute.Webhooks.stripe)) {
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
  }
}

struct SiteRouter: ParserPrinter {
  var body: some Router<SiteRoute> {
    OneOf {
      Route(.case(SiteRoute.home))

      Route(.case(SiteRoute.about)) {
        Path { "about" }
      }

      Route(.case(SiteRoute.account)) {
        Path { "account" }
        AccountRouter()
      }

      Route(.case(SiteRoute.admin)) {
        Path { "admin" }
        AdminRouter()
      }

      Route(.case(SiteRoute.api)) {
        Path { "api" }
        APIRouter()
      }

      Route(.case(SiteRoute.appleDeveloperMerchantIdDomainAssociation)) {
        Path {
          ".well-known"
          "apple-developer-merchantid-domain-association"
        }
      }

      Route(.case(SiteRoute.blog)) {
        Path { "blog" }
        BlogRouter()
      }

      Route(.case(SiteRoute.resume)) {
        Path { "resume" }
      }

      Route(.case(SiteRoute.robots)) {
        Path { "robots.txt" }
      }

      Route(.case(SiteRoute.slackInvite)) {
        Path { "slack-invite" }
      }

      Route(.case(SiteRoute.clips)) {
        Path { "clips" }
        ClipsRouter()
      }

      Route(.case(SiteRoute.collections)) {
        Path { "collections" }
        CollectionsRouter()
      }

      Route(.case(SiteRoute.episode)) {
        Path { "episodes" }
        EpisodeRouter()
      }

      Route(.case(SiteRoute.enterprise)) {
        Path {
          "enterprise"
          Parse(.string.representing(EnterpriseAccount.Domain.self))
        }
        EnterpriseRouter()
      }

      Route(.case(SiteRoute.feed)) {
        Path { "feed" }
        FeedRouter()
      }

      Route(.case(SiteRoute.gifts)) {
        Path { "gifts" }
        GiftsRouter()
      }

      Route(.case(SiteRoute.discounts)) {
        Path {
          "discounts"
          Parse(.string.representing(Stripe.Coupon.ID.self))
        }
        Query {
          Optionally {
            Field("billing") { Pricing.Billing.parser() }
          }
        }
      }

      Route(.case(SiteRoute.endGhosting)) {
        Method.post
        Path {
          "ghosting"
          "end"
        }
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
        InviteRouter()
      }

      Route(.case(SiteRoute.live)) {
        Path { "live" }
        LiveRouter()
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

      Route(.case(SiteRoute.privacy)) {
        Path { "privacy" }
      }

      Route(.case(SiteRoute.resume)) {
        Path { "resume" }
      }

      Route(.case(SiteRoute.subscribe)) {
        Method.post
        Path { "subscribe" }
        SubscribeDataParser()
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

      Route(.case(SiteRoute.team)) { TeamRouter() }

      Route(.case(SiteRoute.teamInviteCode)) {
        Path { "join" }
        JoinRouter()
      }

      Route(.case(SiteRoute.useEpisodeCredit)) {
        Method.post
        Path {
          "episodes"
          Digits().map(.representing(Episode.ID.self))
          "credit"
        }
      }

      Route(.case(SiteRoute.webhooks)) {
        Path { "webhooks" }
        WebhooksRouter()
      }
    }
  }
}

struct SubscribeDataParser: ParserPrinter {
  var body: some Router<SubscribeData?> {
    Body {
      Optionally {
        FormData {
          Parse(
            .memberwise(
              SubscribeData.init(
                coupon:
                isOwnerTakingSeat:
                paymentMethodID:
                pricing:
                referralCode:
                subscriptionID:
                teammates:
                useRegionalDiscount:
              )
            )
          ) {
            Optionally {
              Field(
                SubscribeData.CodingKeys.coupon.rawValue,
                .string.representing(Coupon.ID.self)
              )
            }
            Field(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue, default: false) {
              Bool.parser()
            }
            Field(
              SubscribeData.CodingKeys.paymentMethodID.rawValue,
              .string.representing(PaymentMethod.ID.self)
            )
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
            Optionally {
              Field(
                SubscribeData.CodingKeys.subscriptionID.rawValue,
                .string.filter { !$0.isEmpty }.representing(Stripe.Subscription.ID.self)
              )
            }
            Many {
              Field("teammate", .string.representing(EmailAddress.self))
            }
            Field(SubscribeData.CodingKeys.useRegionalDiscount.rawValue, default: false) {
              Bool.parser()
            }
          }
        }
      }
    }
  }
}

extension Conversion {
  func filter(_ predicate: @escaping (Output) throws -> Bool) -> FilterConversion<Self> {
    FilterConversion(base: self, predicate: predicate)
  }
}

struct FilterConversion<Base: Conversion>: Conversion {
  struct False: Error {}

  let base: Base
  let predicate: (Output) throws -> Bool

  func apply(_ input: Base.Input) throws -> Base.Output {
    let output = try self.base.apply(input)
    guard try self.predicate(output) else { throw False() }
    return output
  }

  func unapply(_ output: Base.Output) throws -> Base.Input {
    guard try self.predicate(output) else { throw False() }
    return try self.base.unapply(output)
  }
}
