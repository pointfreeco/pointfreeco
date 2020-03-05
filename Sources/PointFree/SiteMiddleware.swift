import ApplicativeRouterHttpPipelineSupport
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
    <<< route(router: pointFreeRouter.router, notFound: routeNotFoundMiddleware)
    <| currentUserMiddleware
    >=> currentSubscriptionMiddleware
    >=> render(conn:)

private func render(conn: Conn<StatusLineOpen, T3<(Models.Subscription, EnterpriseAccount?)?, User?, Route>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscriptionAndEnterpriseAccount, user, route) = (conn.data.first, conn.data.second.first, conn.data.second.second)
    let subscriberState = SubscriberState(
      user: user,
      subscriptionAndEnterpriseAccount: subscriptionAndEnterpriseAccount
    )
    let subscription = subscriptionAndEnterpriseAccount.map { subscription, _ in subscription }

    switch route {
    case .about:
      return conn.map(const(user .*. subscriberState .*. route .*. unit))
        |> aboutResponse

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
      return conn
        |> writeStatus(.internalServerError)
        >=> respond(text: "500 Internal Server Error")

    case let .collections(.show(slug)):
      return conn.map(const(user .*. subscriberState .*. slug .*. unit))
        |> collectionMiddleware

    case let .collections(.section(collectionSlug, sectionSlug)):
      return conn.map(const(user .*. subscriberState .*. collectionSlug .*. sectionSlug .*. unit))
        |> collectionSectionMiddleware

    case let .discounts(couponId, billing):
      let subscribeData = SubscribeConfirmationData(
        billing: billing ?? .yearly,
        isOwnerTakingSeat: true,
        referralCode: nil,
        teammates: []
      )
      return conn.map(const(user .*. route .*. subscriberState .*. .personal .*. subscribeData .*. couponId .*. unit))
        |> discountSubscribeConfirmation

    case .endGhosting:
      return conn.map(const(unit))
        |> endGhostingMiddleware

    case .episode(.index):
      return conn
        |> redirect(to: path(to: .home))

    case let .episode(.progress(param: param, percent: percent)):
      return conn.map(const(param .*. user .*. subscriberState .*. percent .*. unit))
        |> progressResponse

    case let .episode(.show(param)):
      return conn.map(const(param .*. user .*. subscriberState .*. route .*. unit))
        |> episodeResponse

    case let .enterprise(.acceptInvite(domain, encryptedEmail, encryptedUserId)):
      return conn.map(const(user .*. domain .*. encryptedEmail .*. encryptedUserId .*. unit))
        |> enterpriseAcceptInviteMiddleware

    case let .enterprise(.landing(domain)):
      return conn.map(const(user .*. subscriberState .*. domain .*. unit))
        |> enterpriseLandingResponse

    case let .enterprise(.requestInvite(domain, request)):
      return conn.map(const(user .*. domain .*. request .*. unit))
        |> enterpriseRequestMiddleware

    case let .expressUnsubscribe(payload):
      return conn.map(const(payload))
        |> expressUnsubscribeMiddleware

    case let .expressUnsubscribeReply(payload):
      return conn.map(const(payload))
        |> expressUnsubscribeReplyMiddleware

    case .feed(.atom), .feed(.episodes):
      return conn.map(const(unit))
        |> episodesRssMiddleware

    case let .gitHubCallback(code, redirect):
      return conn.map(const(user .*. code .*. redirect .*. unit))
        |> gitHubCallbackResponse

    case .home:
      return conn.map(const(user .*. subscriberState .*. route .*. unit))
        |> homeMiddleware

    case let .invite(.accept(inviteId)):
      return conn.map(const(inviteId .*. user .*. unit))
        |> acceptInviteMiddleware

    case let .invite(.addTeammate(email)):
      return conn.map(const(user .*. email .*. unit))
        |> addTeammateViaInviteMiddleware

    case let .invite(.resend(inviteId)):
      return conn.map(const(inviteId .*. user .*. unit))
        |> resendInviteMiddleware

    case let .invite(.revoke(inviteId)):
      return conn.map(const(inviteId .*. user .*. unit))
        |> revokeInviteMiddleware

    case let .invite(.send(email)):
      return conn.map(const(email .*. user .*. unit))
        |> sendInviteMiddleware

    case let .invite(.show(inviteId)):
      return conn.map(const(inviteId .*. user .*. unit))
        |> showInviteMiddleware

    case let .login(redirect):
      return conn.map(const(user .*. redirect .*. unit))
        |> loginResponse

    case .logout:
      return conn.map(const(unit))
        |> logoutResponse

    case .pricingLanding:
      return conn.map(const(
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

    case let .subscribeConfirmation(lane, billing, isOwnerTakingSeat, teammates, referralCode):
      let teammates = lane == .team ? (teammates ?? [""]) : []
      let subscribeData = SubscribeConfirmationData(
        billing: billing ?? .yearly,
        isOwnerTakingSeat: isOwnerTakingSeat ?? true,
        referralCode: referralCode,
        teammates: teammates
      )
      return conn.map(const(user .*. route .*. subscriberState .*. lane .*. subscribeData .*. nil .*. unit))
        |> subscribeConfirmation

    case let .team(.joinLanding(teamInviteCode)):
      return conn.map(const(user .*. subscriberState .*. teamInviteCode .*. unit))
        |> joinTeamLandingMiddleware

    case let .team(.join(teamInviteCode)):
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

    case let .webhooks(.stripe(.knownEvent(event))):
      return conn.map(const(event))
        |> stripeWebhookMiddleware

    case let .webhooks(.stripe(.unknownEvent(event))):
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

public func redirect<A>(
  with route: @escaping (A) -> Route,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> = (id >>> pure)
  )
  ->
  Middleware<StatusLineOpen, ResponseEnded, A, Data> {
    return { conn in
      conn |> redirect(
        to: path(to: route(conn.data)),
        headersMiddleware: headersMiddleware
      )
    }
}

public func redirect<A>(
  to route: Route,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> = (id >>> pure)
  )
  ->
  Middleware<StatusLineOpen, ResponseEnded, A, Data> {
    return redirect(to: path(to: route), headersMiddleware: headersMiddleware)
}

private let canonicalHost = "www.pointfree.co"
private let allowedHosts: [String] = [
  canonicalHost,
  Current.envVars.baseUrl.host ?? canonicalHost,
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private func isAllowed(host: String) -> Bool {
  return allowedHosts.contains(host)
    || host.suffix(8) == "ngrok.io"
}

private let allowedInsecureHosts: [String] = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

