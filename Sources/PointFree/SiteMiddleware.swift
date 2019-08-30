import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Models
import Optics
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tuple
import Views

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requestLogger(logger: { Current.logger.info($0) }, uuid: UUID.init)
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

    case let .discounts(couponId, billing):
      let subscribeData = SubscribeConfirmationData(billing: billing ?? .yearly, teammates: [])
      return conn.map(const(user .*. route .*. subscriberState .*. .personal .*. subscribeData .*. couponId .*. unit))
        |> discountSubscribeConfirmation

    case let .episode(param):
      return conn.map(const(param .*. user .*. subscriberState .*. route .*. unit))
        |> episodeResponse

    case .episodes:
      return conn
        |> redirect(to: path(to: .home))

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

    case .feed(.atom):
      return conn.map(const(Current.episodes()))
        |> atomFeedResponse

    case .feed(.episodes):
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
      let episodes = Current.episodes()
      let allEpisodeCount = AllEpisodeCount(rawValue: episodes.count)
      let episodeHourCount = EpisodeHourCount(rawValue: episodes.reduce(0) { $0 + $1.length } / 3600)
      let freeEpisodeCount = FreeEpisodeCount(rawValue: episodes.lazy.filter { $0.permission == .free }.count)

      return conn.map(const(
        user
          .*. allEpisodeCount
          .*. episodeHourCount
          .*. freeEpisodeCount
          .*. route
          .*. subscriberState
          .*. unit))
        |> pricingLanding

    case .privacy:
      return conn.map(const(user .*. subscriberState .*. route .*. unit))
        |> privacyResponse

    case let .subscribe(data):
      return conn.map(const(data .*. user .*. unit))
        |> subscribeMiddleware

    case let .subscribeConfirmation(lane, billing, teammates):
      let teammates = lane == .team ? (teammates ?? [""]) : []
      let subscribeData = SubscribeConfirmationData(billing: billing ?? .yearly, teammates: teammates)
      return conn.map(const(user .*. route .*. subscriberState .*. lane .*. subscribeData .*. nil .*. unit))
        |> subscribeConfirmation

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
      Current.logger.error("Received invalid webhook \(event.type)")
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

