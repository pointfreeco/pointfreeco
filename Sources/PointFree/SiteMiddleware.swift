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
    <<< redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: canonicalHost)
    <<< route(router: router)
    <<< basicAuth(
      user: AppEnvironment.current.envVars.basicAuth.username,
      password: AppEnvironment.current.envVars.basicAuth.password,
      realm: "Point-Free",
      protect: isProtected
    )
    <| currentUserMiddleware
    >-> currentSubscriptionMiddleware
    >-> render(conn:)

private func render(conn: Conn<StatusLineOpen, T3<Database.Subscription?, Database.User?, Route>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscription, user, route) = (conn.data.first, conn.data.second.first, conn.data.second.second)
    let subscriptionStatus = subscription?.stripeSubscriptionStatus

    switch route {
    case .about:
      return conn.map(const(user .*. unit))
        |> aboutResponse

    case let .account(.confirmEmailChange(userId, emailAddress)):
      return conn.map(const(userId .*. emailAddress .*. unit))
        |> confirmEmailChangeMiddleware

    case .account(.index):
      return conn.map(const(user .*. subscriptionStatus .*. unit))
        |> accountResponse

    case .account(.paymentInfo(.show)):
      return conn.map(const(user .*. unit))
        |> paymentInfoResponse

    case let .account(.paymentInfo(.update(token))):
      return conn.map(const(user .*. token .*. unit))
        |> updatePaymentInfoMiddleware

    case .account(.subscription(.cancel(.show))):
      return conn.map(const(user .*. unit))
        |> confirmCancelResponse

    case .account(.subscription(.cancel(.update))):
      return conn.map(const(user .*. unit))
        |> cancelMiddleware

    case .account(.subscription(.changeSeats(.show))):
      return conn.map(const(user .*. unit))
        |> confirmChangeSeatsResponse

    case let .account(.subscription(.changeSeats(.update(quantity)))):
      return conn.map(const(user .*. quantity .*. unit))
        |> changeSeatsMiddleware

    case .account(.subscription(.downgrade(.show))):
      return conn.map(const(user .*. unit))
        |> confirmDowngradeResponse

    case .account(.subscription(.downgrade(.update))):
      return conn.map(const(user .*. unit))
        |> downgradeMiddleware

    case .account(.subscription(.reactivate)):
      return conn.map(const(user .*. unit))
        |> reactivateMiddleware

    case .account(.subscription(.upgrade(.show))):
      return conn.map(const(user .*. unit))
        |> confirmUpgradeResponse

    case .account(.subscription(.upgrade(.update))):
      return conn.map(const(user .*. unit))
        |> upgradeMiddleware

    case let .account(.update(data)):
      return conn.map(const(data .*. user .*. unit))
        |> updateProfileMiddleware

    case .admin(.index):
      return conn.map(const(user .*. unit))
        |> adminIndex

    case let .admin(.newEpisodeEmail(.send(episodeId))):
      return conn.map(const(user .*. episodeId .*. unit))
        |> sendNewEpisodeEmailMiddleware

    case .admin(.newEpisodeEmail(.show)):
      return conn.map(const(user .*. unit))
        |> showNewEpisodeEmailMiddleware

    case let .episode(param):
      return conn.map(const((param, user, route)))
        |> episodeResponse

    case let .expressUnsubscribe(userId, newsletter):
      return conn.map(const(user .*. userId .*. newsletter .*. unit))
        |> expressUnsubscribeMiddleware

    case let .gitHubCallback(code, redirect):
      return conn.map(const(code .*. redirect .*. unit))
        |> gitHubCallbackResponse

    case let .home(signedUpSuccessfully):
      return conn.map(const(signedUpSuccessfully))
        |> homeResponse

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

    case let .launchSignup(email):
      return conn.map(const(email))
        |> signupResponse

    case let .login(redirect):
      return conn.map(const(redirect))
        |> loginResponse

    case .logout:
      return conn.map(const(unit))
        |> logoutResponse

    case let .pricing(plan, quantity):
      let pricing: Pricing
      if let quantity = quantity {
        pricing = .team(quantity)
      } else if let plan = plan, let billing = Pricing.Billing(rawValue: plan) {
        pricing = .individual(billing)
      } else {
        pricing = .default
      }

      return conn.map(const(user .*. pricing .*. route .*. unit))
        |> pricingResponse

    case .secretHome:
      return conn.map(const(user .*. subscriptionStatus .*. route .*. unit))
        |> secretHomeMiddleware

    case let .subscribe(data):
      return conn.map(const(data .*. user .*. unit))
        |> subscribeMiddleware

    case .team(.show):
      return conn.map(const(user .*. unit))
        |> teamResponse

    case let .team(.remove(teammateId)):
      return conn.map(const(teammateId .*. user .*. unit))
        |> removeTeammateMiddleware

    case .terms:
      return conn.map(const(user .*. unit))
        |> termsResponse
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

private let allowedInsecureHosts: [String] = [
  "127.0.0.1",
  "0.0.0.0",
  "localhost"
]

private func isProtected(route: Route) -> Bool {
  switch route {
  case .about,
       .admin,
       .account,
       .expressUnsubscribe,
       .episode,
       .gitHubCallback,
       .invite,
       .login,
       .logout,
       .pricing,
       .secretHome,
       .subscribe,
       .team,
       .terms:

    return true

  case .home,
       .launchSignup:
    
    return false
  }
}
