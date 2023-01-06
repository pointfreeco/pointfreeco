import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tuple
import Views

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requestLogger(logger: { Current.logger.log(.info, "\($0)") }, uuid: UUID.init)
  <<< requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
  <<< redirectUnrelatedHosts(isAllowedHost: { isAllowed(host: $0) }, canonicalHost: canonicalHost)
  <<< router(notFound: routeNotFoundMiddleware)
  <| currentUserMiddleware
  >=> currentSubscriptionMiddleware
  >=> render(conn:)

private func router<A>(
  notFound: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data> = notFound(
    respond(text: "Not Found"))
)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, SiteRoute, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data>
{

  return { middleware in
    @Dependency(\.siteRouter) var siteRouter

    return { conn in
      let route: SiteRoute?
      do {
        route = try siteRouter.match(request: conn.request)
      } catch {
        route = nil
        #if DEBUG
          print(error)
        #endif
      }
      return
        route
        .map(const >>> conn.map >>> middleware)
        ?? notFound(conn)
    }
  }
}

private func render(
  conn: Conn<StatusLineOpen, T3<(Models.Subscription, EnterpriseAccount?)?, User?, SiteRoute>>
)
  -> IO<Conn<ResponseEnded, Data>>
{
  @Dependency(\.siteRouter) var siteRouter

  let (subscriptionAndEnterpriseAccount, user, route) = (
    conn.data.first, conn.data.second.first, conn.data.second.second
  )
  let subscriberState = SubscriberState(
    user: user,
    subscriptionAndEnterpriseAccount: subscriptionAndEnterpriseAccount
  )
  let subscription = subscriptionAndEnterpriseAccount.map { subscription, _ in subscription }

  switch route {
  case .about:
    return pure(aboutResponse(conn.map { _ in (user, subscriberState, route) }))

  case let .account(account):
    return conn.map(const(subscription .*. user .*. subscriberState .*. account .*. unit))
      |> accountMiddleware

  case let .admin(route):
    return conn.map(const(user .*. route .*. unit))
      |> adminMiddleware

  case let .api(apiRoute):
    return conn.map(const(user .*. apiRoute .*. unit))
      |> apiMiddleware

  case .appleDeveloperMerchantIdDomainAssociation:
    return conn.map(const(unit))
      |> appleDeveloperMerchantIdDomainAssociationMiddleware

  case let .blog(subRoute):
    return conn.map(const(user .*. subscriberState .*. route .*. subRoute .*. unit))
      |> blogMiddleware

  case .collections(.index):
    return conn.map(const(user .*. subscriberState .*. route .*. unit))
      |> collectionsIndexMiddleware

  case let .collections(.collection(slug, .show)):
    return conn.map(const(user .*. subscriberState .*. route .*. slug .*. unit))
      |> collectionMiddleware

  case let .collections(.collection(collectionSlug, .section(sectionSlug, .show))):
    return
      conn
      .map(const(user .*. subscriberState .*. route .*. collectionSlug .*. sectionSlug .*. unit))
      |> collectionSectionMiddleware

  case let .collections(.collection(collectionSlug, .section(_, .episode(episodeParam)))):
    return
      conn
      .map(const(episodeParam .*. user .*. subscriberState .*. route .*. collectionSlug .*. unit))
      |> episodeResponse

  case let .discounts(couponId, billing):
    let subscribeData = SubscribeConfirmationData(
      billing: billing ?? .yearly,
      isOwnerTakingSeat: true,
      referralCode: nil,
      teammates: [],
      useRegionalDiscount: false
    )
    return conn.map(
      const(
        user .*. route .*. subscriberState .*. .personal .*. subscribeData .*. couponId .*. unit))
      |> discountSubscribeConfirmation

  case .endGhosting:
    return conn.map(const(unit))
      |> endGhostingMiddleware

  case .episode(.index):
    return conn
      |> redirect(to: siteRouter.path(for: .home))

  case let .episode(.progress(param: param, percent: percent)):
    return conn.map(const(param .*. user .*. subscriberState .*. percent .*. unit))
      |> progressResponse

  case let .episode(.show(param)):
    return conn.map(const(param .*. user .*. subscriberState .*. route .*. nil .*. unit))
      |> episodeResponse

  case let .enterprise(domain, .acceptInvite(encryptedEmail, encryptedUserId)):
    return conn.map(const(user .*. domain .*. encryptedEmail .*. encryptedUserId .*. unit))
      |> enterpriseAcceptInviteMiddleware

  case let .enterprise(domain, .landing):
    return conn.map(const(user .*. subscriberState .*. domain .*. unit))
      |> enterpriseLandingResponse

  case let .enterprise(domain, .requestInvite(request)):
    return conn.map(const(user .*. domain .*. request .*. unit))
      |> enterpriseRequestMiddleware

  case let .expressUnsubscribe(payload):
    return conn.map(const(payload))
      |> expressUnsubscribeMiddleware

  case let .expressUnsubscribeReply(payload):
    return conn.map(const(payload))
      |> expressUnsubscribeReplyMiddleware

  case .feed(.atom), .feed(.episodes):
    return IO {
      guard !Current.envVars.emergencyMode
      else {
        return
          conn
          .writeStatus(.internalServerError)
          .respond(json: "{}")
      }
      return episodesRssMiddleware(
        conn.map { _ in }
      )
    }

  case let .gifts(giftsRoute):
    return conn.map(
      const(user .*. subscription .*. subscriberState .*. route .*. giftsRoute .*. unit)
    )
      |> giftsMiddleware

  case let .gitHubCallback(code, redirect):
    return conn.map(const(user .*. code .*. redirect .*. unit))
      |> gitHubCallbackResponse

  case .home:
    return conn.map(const(user .*. subscriberState .*. route .*. unit))
      |> homeMiddleware

  case let .invite(.addTeammate(email)):
    return conn.map(const(user .*. email .*. unit))
      |> addTeammateViaInviteMiddleware

  case let .invite(.invitation(inviteId, .accept)):
    return conn.map(const(inviteId .*. user .*. unit))
      |> acceptInviteMiddleware

  case let .invite(.invitation(inviteId, .resend)):
    return conn.map(const(inviteId .*. user .*. unit))
      |> resendInviteMiddleware

  case let .invite(.invitation(inviteId, .revoke)):
    return conn.map(const(inviteId .*. user .*. unit))
      |> revokeInviteMiddleware

  case let .invite(.invitation(inviteId, .show)):
    return conn.map(const(inviteId .*. user .*. unit))
      |> showInviteMiddleware

  case let .invite(.send(email)):
    return conn.map(const(email .*. user .*. unit))
      |> sendInviteMiddleware

  case let .login(redirect):
    return conn.map(const(user .*. redirect .*. unit))
      |> loginResponse

  case .logout:
    return conn.map(const(unit))
      |> logoutResponse

  case .pricingLanding:
    return conn.map(
      const(
        user
          .*. route
          .*. subscriberState
          .*. unit))
      |> pricingLanding

  case .privacy:
    return conn.map(const(user .*. subscriberState .*. route .*. unit))
      |> privacyResponse

  case let .subscribe(data):
    return conn.map(const(user .*. data .*. unit))
      |> subscribeMiddleware

  case let .subscribeConfirmation(
    lane, billing, isOwnerTakingSeat, teammates, referralCode, useRegionalDiscount
  ):
    let teammates = lane == .team ? (teammates ?? [""]) : []
    let subscribeData = SubscribeConfirmationData(
      billing: billing ?? .yearly,
      isOwnerTakingSeat: isOwnerTakingSeat ?? true,
      referralCode: referralCode,
      teammates: teammates,
      useRegionalDiscount: useRegionalDiscount ?? false
    )
    return conn.map(
      const(user .*. route .*. subscriberState .*. lane .*. subscribeData .*. nil .*. unit))
      |> subscribeConfirmation

  case let .team(.join(teamInviteCode, .landing)):
    return conn.map(const(user .*. subscriberState .*. teamInviteCode .*. unit))
      |> joinTeamLandingMiddleware

  case let .team(.join(teamInviteCode, .confirm)):
    return conn.map(const(user .*. subscriberState .*. teamInviteCode .*. unit))
      |> joinTeamMiddleware

  case .team(.leave):
    return conn.map(const(user .*. subscriberState .*. unit))
      |> leaveTeamMiddleware

  case let .team(.remove(teammateId)):
    return conn.map(const(teammateId .*. user .*. unit))
      |> removeTeammateMiddleware

  case let .useEpisodeCredit(episodeId):
    return conn.map(const(Either.right(episodeId) .*. user .*. subscriberState .*. route .*. unit))
      |> useCreditResponse

  case let .webhooks(.stripe(.paymentIntents(event))):
    return conn.map(const(event))
      |> stripePaymentIntentsWebhookMiddleware

  case let .webhooks(.stripe(.subscriptions(event))):
    return conn.map(const(event))
      |> stripeSubscriptionsWebhookMiddleware

  case let .webhooks(.stripe(.unknown(event))):
    Current.logger.log(.error, "Received invalid webhook \(event.type)")
    return conn
      |> writeStatus(.internalServerError)
      >=> respond(text: "We don't support this event.")

  case .webhooks(.stripe(.fatal)):
    return conn
      |> writeStatus(.internalServerError)
      >=> respond(text: "We don't support this event.")
  }
}

extension Conn where Step == StatusLineOpen {
  public func redirect(
    to route: SiteRoute,
    headersMiddleware: (Conn<HeadersOpen, A>) -> Conn<HeadersOpen, A> = { $0 }
  ) -> Conn<ResponseEnded, Data> {
    @Dependency(\.siteRouter) var siteRouter

    return self.redirect(
      to: siteRouter.path(for: route),
      headersMiddleware: headersMiddleware
    )
  }

  public func redirect(
    with route: (A) -> SiteRoute,
    headersMiddleware: (Conn<HeadersOpen, A>) -> Conn<HeadersOpen, A> = { $0 }
  ) -> Conn<ResponseEnded, Data> {
    @Dependency(\.siteRouter) var siteRouter

    return self.redirect(
      to: siteRouter.path(for: route(self.data)),
      headersMiddleware: headersMiddleware
    )
  }

  public func redirect(
    to route: SiteRoute,
    headersMiddleware: (Conn<HeadersOpen, A>) async -> Conn<HeadersOpen, A> = { $0 }
  ) async -> Conn<ResponseEnded, Data> {
    @Dependency(\.siteRouter) var siteRouter

    return await self.redirect(
      to: siteRouter.path(for: route),
      headersMiddleware: headersMiddleware
    )
  }

  public func redirect(
    with route: (A) -> SiteRoute,
    headersMiddleware: (Conn<HeadersOpen, A>) async -> Conn<HeadersOpen, A> = { $0 }
  ) async -> Conn<ResponseEnded, Data> {
    @Dependency(\.siteRouter) var siteRouter

    return await self.redirect(
      to: siteRouter.path(for: route(self.data)),
      headersMiddleware: headersMiddleware
    )
  }
}

public func redirect<A>(
  with route: @escaping (A) -> SiteRoute,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> = (id >>> pure)
)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data>
{
  @Dependency(\.siteRouter) var siteRouter

  return { conn in
    conn
      |> redirect(
        to: siteRouter.path(for: route(conn.data)),
        headersMiddleware: headersMiddleware
      )
  }
}

public func redirect<A>(
  to route: SiteRoute,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> = (id >>> pure)
) -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {
  @Dependency(\.siteRouter) var siteRouter

  return redirect(to: siteRouter.path(for: route), headersMiddleware: headersMiddleware)
}

private let canonicalHost = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalHost,
  Current.envVars.baseUrl.host ?? canonicalHost,
  "127.0.0.1",
  "0.0.0.0",
  "localhost",
]

private func isAllowed(host: String) -> Bool {
  return allowedHosts.contains(host)
    || host.suffix(8) == "ngrok.io"
}

private let allowedInsecureHosts: [String] = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost",
]
