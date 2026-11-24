import CasePaths
import Either
import EmailAddress
import Foundation
import GitHub
import Models
import Prelude
import Stripe
import Tagged
import URLRouting
import UrlFormEncoding

public enum EncryptedTag {}
public typealias Encrypted<A> = Tagged<EncryptedTag, A>

@CasePathable
public indirect enum SiteRoute: Equatable {
  case about
  case betas(Betas = .landing)
  case theWay
  case account(Account = .index)
  case admin(Admin = .index)
  case api(Api)
  case auth(Auth)
  case blog(Blog = .index)
  case clips(ClipsRoute)
  case collections(Collections = .index)
  case discounts(code: Stripe.Coupon.ID, Pricing.Billing?, Pricing.Plan? = nil)
  case gifts(Gifts = .index)
  case endGhosting
  case enterprise(EnterpriseAccount.Domain, Enterprise = .landing)
  case episodes(EpisodesRoute = .list(.all))
  case expressUnsubscribe(payload: Encrypted<String>)
  case expressUnsubscribeReply(MailgunForwardPayload)
  case feed(Feed)
  case home
  case invite(Invite)
  case live(Live)
  case officeHours(OfficeHoursRoute = .index())
  case pricingLanding
  case privacy
  case resume
  case robots
  case search(
    query: String? = nil,
    access: SearchAccess? = nil,
    scope: SearchScope? = nil,
    sort: SearchSort? = nil
  )
  case slackInvite
  case subscribe(SubscribeData? = nil)
  case subscribeConfirmation(
    lane: Pricing.Lane,
    billing: Pricing.Billing? = nil,
    isOwnerTakingSeat: Bool? = nil,
    plan: Pricing.Plan? = nil,
    teammates: [EmailAddress]? = nil,
    referralCode: User.ReferralCode? = nil,
    useRegionalDiscount: Bool? = nil
  )
  case team(Team)
  case teamInviteCode(TeamInviteCode)
  case webhooks(Webhooks)
  case wellKnown(WellKnown)

  @CasePathable
  public enum Auth: Equatable {
    case authLanding(kind: Kind? = nil, redirect: String? = nil)
    case codeLanding(email: EmailAddress, redirect: String? = nil)
    case connectGitHub(redirect: String? = nil)
    case connectGitHubLanding(redirect: String? = nil)
    case emailAuth(email: EmailAddress, redirect: String? = nil)
    case failureLanding(redirect: String?)
    case gitHubAuth(redirect: String?)
    case gitHubCallback(code: String?, redirect: String?, state: UUID? = nil)
    case linkGitHubLanding(redirect: String? = nil)
    case logout
    case updateGitHub(redirect: String?)
    case verifyLoginCode(
      email: EmailAddress, code: EmailLoginCode.Code, redirect: String? = nil)

    public enum Kind: String, CaseIterable {
      case login
      case signUp
      case slack
    }
  }

  @CasePathable
  public enum Betas: Equatable {
    case landing
    case join(repo: String)
  }

  @CasePathable
  public enum Blog: Equatable {
    case feed
    case index
    case slackFeed
    case show(Either<String, BlogPost.ID>)

    public static func show(slug: String) -> Blog { .show(.left(slug)) }
    public static func show(id: BlogPost.ID) -> Blog { .show(.right(id)) }
    public static func show(_ post: BlogPost) -> Blog { .show(slug: post.slug) }
  }

  @CasePathable
  public enum Collections: Equatable {
    case index
    case collection(Episode.Collection.Slug, Collection = .show)

    @CasePathable
    public enum Collection: Equatable {
      case show
      case section(Episode.Collection.Section.Slug, Section = .show)
    }

    @CasePathable
    public enum Section: Equatable {
      case episode(Either<String, Episode.ID>)
      case progress(param: Either<String, Episode.ID>, percent: Int)
      case show
    }
  }

  @CasePathable
  public enum Enterprise: Equatable {
    case acceptInvite(email: Encrypted<String>, userId: Encrypted<String>)
    case landing
    case requestInvite(EnterpriseRequestFormData)
  }

  public enum SearchAccess: String, CaseIterable, Equatable {
    case free
    case subscriberOnly = "subscriber-only"
  }

  public enum SearchScope: String, CaseIterable, Equatable {
    case code
    case dialogue
    case titles
  }

  public enum SearchSort: String, CaseIterable, Equatable {
    case newest
    case oldest
  }

  @CasePathable
  public enum EpisodesRoute: Equatable {
    case list(ListType)
    case episode(param: Either<String, Episode.ID>, EpisodeRoute)

    public static func show(_ episode: Episode) -> Self {
      .episode(param: .left(episode.slug), .show())
    }

    @CasePathable
    public enum ListType: Equatable {
      case all
      case free
      case history
    }

    @CasePathable
    public enum EpisodeRoute: Equatable {
      case progress(percent: Int)
      case show(collection: Episode.Collection.Slug? = nil)
      case useCredit
    }
  }

  @CasePathable
  public enum Feed: Equatable {
    case atom
    case episodes
    case slack
  }

  @CasePathable
  public enum Invite: Equatable {
    case addTeammate(EmailAddress?)
    case invitation(TeamInvite.ID, Invitation = .show)
    case send(EmailAddress?)

    @CasePathable
    public enum Invitation: Equatable {
      case accept
      case resend
      case revoke
      case show
    }
  }

  @CasePathable
  public enum Team: Equatable {
    case join(Models.Subscription.TeamInviteCode, Join = .landing)
    case leave
    case remove(User.ID)

    @CasePathable
    public enum Join: Equatable {
      case confirm
      case landing
    }
  }

  @CasePathable
  public enum Webhooks: Equatable {
    case stripe(_Stripe)

    @CasePathable
    public enum _Stripe: Equatable {
      case paymentIntents(Event<PaymentIntent>)
      case subscriptions(Event<Either<Invoice, Stripe.Subscription>>)
      case unknown(Event<Prelude.Unit>)
      case fatal
    }
  }

  @CasePathable
  public enum WellKnown {
    case appleDeveloperMerchantIdDomainAssociation
    case atProto
  }
}

struct SlugOrID<ID: RawRepresentable>: ParserPrinter where ID.RawValue == Int {
  var body: some ParserPrinter<Substring, Either<String, ID>> {
    OneOf {
      Parse {
        Digits().map(.representing(ID.self).map(.case(Either<String, ID>.right)))
        End()
      }
      Parse(.string.map(.case(Either<String, ID>.left)))
    }
  }
}

struct BlogRouter: ParserPrinter {
  var body: some Router<SiteRoute.Blog> {
    OneOf(output: SiteRoute.Blog.self) {
      Route(.case(\.index))

      Route(.case(\.feed)) {
        Path {
          "feed"
          "atom.xml"
        }
      }

      Route(.case(\.slackFeed)) {
        Path {
          "feed"
          "slack-atom.xml"
        }
      }

      Route(.case(\.show)) {
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
    OneOf(output: SiteRoute.Collections.self) {
      Route(.case(\.index))

      Route(.case(SiteRoute.Collections.collection)) {
        Path { Parse(.string.representing(Episode.Collection.Slug.self)) }

        OneOf(output: SiteRoute.Collections.Collection.self) {
          Route(.case(\.show))

          Route(.case(SiteRoute.Collections.Collection.section)) {
            Path { Parse(.string.representing(Episode.Collection.Section.Slug.self)) }

            OneOf(output: SiteRoute.Collections.Section.self) {
              Route(.case(\.show))

              Route(.case(\.episode)) {
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

struct EpisodesRouter: ParserPrinter {
  var body: some Router<SiteRoute.EpisodesRoute> {
    OneOf(output: SiteRoute.EpisodesRoute.self) {
      Route(.case(\.list)) {
        OneOf(output: SiteRoute.EpisodesRoute.ListType.self) {
          Route(.case(\.all))
          Route(.case(\.free)) {
            Path { "free" }
          }
          Route(.case(\.history)) {
            Path { "history" }
          }
        }
      }

      Route(.case(SiteRoute.EpisodesRoute.episode)) {
        Path { SlugOrID<Episode.ID>() }

        OneOf(output: SiteRoute.EpisodesRoute.EpisodeRoute.self) {
          Route(.case(\.show)) {
            Always(Episode.Collection.Slug?.none)
          }

          Route(.case(\.progress)) {
            Method.post
            Path { "progress" }
            Query {
              Field("percent") { Digits() }
            }
          }

          Route(.case(\.useCredit)) {
            Method.post
            Path { "credit" }
          }
        }
      }
    }
  }
}

struct EnterpriseRouter: ParserPrinter {
  var body: some Router<SiteRoute.Enterprise> {
    OneOf(output: SiteRoute.Enterprise.self) {
      Route(.case(\.landing))

      Route(.case(\.requestInvite)) {
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
    OneOf(output: SiteRoute.Feed.self) {
      Route(.case(\.atom)) {
        Path { "atom.xml" }
      }

      Route(.case(\.episodes)) {
        Path { "episodes.xml" }
      }

      Route(.case(\.slack)) {
        Path { "slack.xml" }
      }
    }
  }
}

struct InviteRouter: ParserPrinter {
  var body: some Router<SiteRoute.Invite> {
    OneOf(output: SiteRoute.Invite.self) {
      Route(.case(\.addTeammate)) {
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

      Route(.case(\.invitation)) {
        Path { UUID.parser().map(.representing(TeamInvite.ID.self)) }

        OneOf(output: SiteRoute.Invite.Invitation.self) {
          Route(.case(\.show))

          Route(.case(\.accept)) {
            Method.post
            Path { "accept" }
          }

          Route(.case(\.resend)) {
            Method.post
            Path { "resend" }
          }

          Route(.case(\.revoke)) {
            Method.post
            Path { "revoke" }
          }
        }
      }

      Route(.case(\.send)) {
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

        OneOf(output: SiteRoute.Team.Join.self) {
          Route(.case(\.landing))

          Route(.case(\.confirm)) {
            Method.post
          }
        }
      }

      Parse {
        Path {
          "account"
          "team"
        }

        OneOf(output: SiteRoute.Team.self) {
          Route(.case(\.leave)) {
            Method.post
            Path { "leave" }
          }

          Route(.case(\.remove)) {
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
    OneOf(output: SiteRoute.Webhooks.self) {
      Route(.case(\.stripe)) {
        Method.post
        Path { "stripe" }

        OneOf(output: SiteRoute.Webhooks._Stripe.self) {
          Route(.case(\.paymentIntents)) {
            Body(
              .json(
                Stripe.Event<PaymentIntent>.self,
                decoder: Stripe.jsonDecoder,
                encoder: Stripe.jsonEncoder
              )
            )
          }

          Route(.case(\.subscriptions)) {
            Body(
              .json(
                Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
                decoder: Stripe.jsonDecoder,
                encoder: Stripe.jsonEncoder
              )
            )
          }

          Route(.case(\.unknown)) {
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
}

struct SiteRouter: ParserPrinter {
  var body: some Router<SiteRoute> {
    OneOf(output: SiteRoute.self) {
      Route(.case(\.home))

      Route(.case(\.about)) {
        Path { "about" }
      }

      Route(.case(\.betas)) {
        Path { "beta-previews" }
        OneOf {
          Route(.case(SiteRoute.Betas.landing))
          Route(.case(SiteRoute.Betas.join)) {
            Method.post
            Path {
              "join"
              Parse(.string)
            }
          }
        }
      }

      Route(.case(\.theWay)) {
        Path { "the-way" }
      }

      Route(.case(\.account)) {
        Path { "account" }
        AccountRouter()
      }

      Route(.case(\.admin)) {
        Path { "admin" }
        AdminRouter()
      }

      Route(.case(\.api)) {
        Path { "api" }
        APIRouter()
      }

      Route(.case(\.wellKnown)) {
        Path { ".well-known" }
        OneOf(output: SiteRoute.WellKnown.self) {
          Route(.case(\.appleDeveloperMerchantIdDomainAssociation)) {
            Path {
              "apple-developer-merchantid-domain-association"
            }
          }
          Route(.case(\.atProto)) {
            Path {
              "atproto-did"
            }
          }
        }
      }

      Route(.case(\.auth)) {
        AuthRouter()
      }

      Route(.case(\.blog)) {
        Path { "blog" }
        BlogRouter()
      }

      Route(.case(\.resume)) {
        Path { "resume" }
      }

      Route(.case(\.robots)) {
        Path { "robots.txt" }
      }

      Route(.case(SiteRoute.search)) {
        Path { "search" }
        Query {
          Optionally {
            Field("q", .string)
          }
          Optionally {
            Field("access") { SiteRoute.SearchAccess.parser() }
          }
          Optionally {
            Field("scope") { SiteRoute.SearchScope.parser() }
          }
          Optionally {
            Field("sort") { SiteRoute.SearchSort.parser() }
          }
        }
      }

      Route(.case(\.slackInvite)) {
        OneOf {
          Path { "slack-invite" }
          Path { "slack" }
        }
      }

      Route(.case(\.clips)) {
        Path { "clips" }
        ClipsRouter()
      }

      Route(.case(\.collections)) {
        Path { "collections" }
        CollectionsRouter()
      }

      Route(.case(\.episodes)) {
        Path { "episodes" }
        EpisodesRouter()
      }

      Route(.case(\.enterprise)) {
        Path {
          "enterprise"
          Parse(.string.representing(EnterpriseAccount.Domain.self))
        }
        EnterpriseRouter()
      }

      Route(.case(\.feed)) {
        Path { "feed" }
        FeedRouter()
      }

      Route(.case(\.gifts)) {
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
        Query {
          Optionally {
            Field("plan") { Pricing.Plan.parser() }
          }
        }
      }

      Route(.case(\.endGhosting)) {
        Path {
          "ghosting"
          "end"
        }
      }

      Parse {
        Path { "newsletters" }

        OneOf(output: SiteRoute.self) {
          Route(.case(\.expressUnsubscribe)) {
            Path { "express-unsubscribe" }
            Query {
              Field("payload", .string.representing(Encrypted.self))
            }
          }

          Route(.case(\.expressUnsubscribeReply)) {
            Method.post
            Path { "express-unsubscribe-reply" }
            Body(.form(MailgunForwardPayload.self, decoder: formDecoder))
          }
        }
      }

      Route(.case(\.invite)) {
        Path { "invites" }
        InviteRouter()
      }

      Route(.case(\.live)) {
        Path { "live" }
        LiveRouter()
      }

      Route(.case(\.officeHours)) {
        Path { "office-hours" }
        OfficeHoursRouter()
      }

      Route(.case(\.pricingLanding)) {
        Path { "pricing" }
      }

      Route(.case(\.privacy)) {
        Path { "privacy" }
      }

      Route(.case(\.resume)) {
        Path { "resume" }
      }

      Route(.case(\.subscribe)) {
        Method.post
        Path { "subscribe" }
        SubscribeDataParser()
      }

      Route(.case(SiteRoute.subscribeConfirmation)) {
        Parse(
          .convert(
            apply: { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5) },
            unapply: { ($0, ($1, $2, $3, $4, $5, $6)) }
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
              Field("plan") { Pricing.Plan.parser() }
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

      Route(.case(\.team)) { TeamRouter() }

      Route(.case(\.teamInviteCode)) {
        Path { "join" }
        JoinRouter()
      }

      Route(.case(\.webhooks)) {
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
            Parse(.memberwise(Pricing.init(plan:billing:quantity:))) {
              Field("pricing[plan]") { Pricing.Plan.parser() }
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

private struct AuthRouter: ParserPrinter {
  var body: some Router<SiteRoute.Auth> {
    OneOf(output: SiteRoute.Auth.self) {
      Route(.case(SiteRoute.Auth.codeLanding)) {
        Path { "email-auth" }
        Query {
          Field("email", .string.representing(EmailAddress.self))
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(\.connectGitHub)) {
        Method.post
        Path { "connect-github" }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(\.connectGitHubLanding)) {
        Path { "connect-github" }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(SiteRoute.Auth.emailAuth)) {
        Method.post
        Path { "email-auth" }
        Body {
          FormData {
            Field("email", .string.representing(EmailAddress.self))
          }
        }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(\.failureLanding)) {
        Path { "github-failure" }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }
      Route(.case(\.gitHubAuth)) {
        Path { "authenticate" }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(SiteRoute.Auth.gitHubCallback)) {
        Path { "github-auth" }
        Query {
          Optionally {
            Field("code")
          }
          Optionally {
            Field("redirect")
          }
          Optionally {
            Field("state") { UUID.parser() }
          }
        }
      }

      Route(.case(\.linkGitHubLanding)) {
        Path { "link-github" }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(SiteRoute.Auth.authLanding)) {
        OneOf {
          Parse {
            Path { "login" }
            Always(Optional(SiteRoute.Auth.Kind.login))
          }
          Parse {
            Path { "signup" }
            Always(Optional(SiteRoute.Auth.Kind.signUp))
          }
          Parse {
            Path { "auth" }
            Query {
              Optionally {
                Field("kind", .string.representing(SiteRoute.Auth.Kind.self))
              }
            }
          }
        }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(\.logout)) {
        Path { "logout" }
      }

      Route(.case(\.updateGitHub)) {
        Method.post
        Path { "update-github" }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }

      Route(.case(SiteRoute.Auth.verifyLoginCode)) {
        Method.post
        Path {
          "email-auth"
          "verify"
        }
        Body {
          FormData {
            Field("email", .string.representing(EmailAddress.self))
            Field("code", .string.representing(EmailLoginCode.Code.self))
          }
        }
        Query {
          Optionally {
            Field("redirect")
          }
        }
      }
    }
  }
}
