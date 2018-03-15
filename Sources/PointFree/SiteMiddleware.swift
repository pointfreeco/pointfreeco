import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import Styleguide
import Tuple

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requestLogger { AppEnvironment.current.logger.info($0) }
    <<< requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(isAllowedHost: isAllowed(host:), canonicalHost: canonicalHost)
    <<< route(router: router, notFound: routeNotFoundMiddleware)
    <| currentUserMiddleware
    >-> currentSubscriptionMiddleware
    >-> render(conn:)

private func render(conn: Conn<StatusLineOpen, T3<Database.Subscription?, Database.User?, Route>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscription, user, route) = (conn.data.first, conn.data.second.first, conn.data.second.second)
    let subscriptionStatus = subscription?.stripeSubscriptionStatus

    switch route {
    case .about:
      return conn.map(const(user .*. subscriptionStatus .*. route .*. unit))
        |> aboutResponse

    case let .account(.confirmEmailChange(userId, emailAddress)):
      return conn.map(const(userId .*. emailAddress .*. unit))
        |> confirmEmailChangeMiddleware

    case .account(.index):
      return conn.map(const(user .*. unit))
        |> accountResponse

    case let .account(.paymentInfo(.show(expand))):
      return conn.map(const(user .*. (expand ?? false) .*. unit))
        |> paymentInfoResponse

    case let .account(.paymentInfo(.update(token))):
      return conn.map(const(user .*. token .*. unit))
        |> updatePaymentInfoMiddleware

    case .account(.subscription(.cancel)):
      return conn.map(const(user .*. unit))
        |> cancelMiddleware

    case .account(.subscription(.change(.show))):
      return conn.map(const(user .*. unit))
        |> subscriptionChangeShowResponse

    case let .account(.subscription(.change(.update(pricing)))):
      return conn.map(const(user .*. pricing .*. unit))
        |> subscriptionChangeMiddleware

    case .account(.subscription(.reactivate)):
      return conn.map(const(user .*. unit))
        |> reactivateMiddleware

    case let .account(.update(data)):
      return conn.map(const(data .*. user .*. unit))
        |> updateProfileMiddleware

    case let .admin(.episodeCredits(.add(userId: userId, episodeSequence: episodeSequence))):
      return conn.map(const(user .*. userId .*. episodeSequence .*. unit))
        |> redeemEpisodeCreditMiddleware

    case .admin(.episodeCredits(.show)):
      return conn.map(const(user .*. unit))
        |> showEpisodeCreditsMiddleware

    case .admin(.index):
      return conn.map(const(user .*. unit))
        |> adminIndex

    case .admin(.freeEpisodeEmail(.index)):
      return conn.map(const(user .*. unit))
        |> indexFreeEpisodeEmailMiddleware

    case let .admin(.freeEpisodeEmail(.send(episodeId))):
      return conn.map(const(user .*. episodeId .*. unit))
        |> sendFreeEpisodeEmailMiddleware

    case let .admin(.newEpisodeEmail(.send(episodeId))):
      return conn.map(const(user .*. episodeId .*. unit))
        |> sendNewEpisodeEmailMiddleware

    case .admin(.newEpisodeEmail(.show)):
      return conn.map(const(user .*. unit))
        |> showNewEpisodeEmailMiddleware

    case .appleDeveloperMerchantIdDomainAssociation:
      return conn.map(const(unit))
        |> appleDeveloperMerchantIdDomainAssociationMiddleware

    case let .episode(param):
      return conn.map(const(param .*. user .*. subscriptionStatus .*. route .*. unit))
        |> episodeResponse

    case let .expressUnsubscribe(userId, newsletter):
      return conn.map(const(userId .*. newsletter .*. unit))
        |> expressUnsubscribeMiddleware

    case let .expressUnsubscribeReply(payload):
      return conn.map(const(payload))
        |> expressUnsubscribeReplyMiddleware

    case .feed(.atom):
      return conn.map(const(AppEnvironment.current.episodes()))
        |> atomFeedResponse

    case let .gitHubCallback(code, redirect):
      return conn.map(const(user .*. code .*. redirect .*. unit))
        |> gitHubCallbackResponse

    case let .invite(.accept(inviteId)):
      return conn.map(const(inviteId .*. user .*. unit))
        |> acceptInviteMiddleware

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

    case let .pricing(pricing, expand):
      return conn.map(const(user .*. (pricing ?? .default) .*. (expand ?? false) .*. route .*. unit))
        |> pricingResponse

    case .privacy:
      return conn.map(const(user .*. subscriptionStatus .*. route .*. unit))
        |> privacyResponse

    case .home:
      return conn.map(const(user .*. subscriptionStatus .*. route .*. unit))
        |> homeMiddleware

    case let .subscribe(data):
      return conn.map(const(data .*. user .*. unit))
        |> subscribeMiddleware

    case let .team(.remove(teammateId)):
      return conn.map(const(teammateId .*. user .*. unit))
        |> removeTeammateMiddleware

    case let .useEpisodeCredit(episodeId):
      return conn.map(const(Either.right(episodeId.unwrap) .*. user .*. subscriptionStatus .*. route .*. unit))
        |> useCreditResponse

    case let .webhooks(.stripe(.invoice(event))):
      return conn.map(const(event))
        |> stripeInvoiceWebhookMiddleware

    case .webhooks(.stripe(.fallthrough)):
      return conn
        |> writeStatus(.ok)
        >-> end
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
  AppEnvironment.current.envVars.baseUrl.host ?? canonicalHost,
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
