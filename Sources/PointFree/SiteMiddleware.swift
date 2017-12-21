import ApplicativeRouterHttpPipelineSupport
import Foundation
import HttpPipeline
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
    <| (
      readSessionCookieMiddleware
        >-> render(conn:)
)

private func render(conn: Conn<StatusLineOpen, Tuple2<Database.User?, Route>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (user, route) = lower <| conn.data
    switch route {
    case .about:
      return conn.map(const(unit))
        |> aboutResponse

    case .account:
      return conn.map(const(unit))
        |> accountResponse

    case let .episode(param):
      return conn.map(const((param, user, route)))
        |> episodeResponse

    case let .gitHubCallback(code, redirect):
      return conn.map(const((code, redirect)))
        |> gitHubCallbackResponse

    case let .home(signedUpSuccessfully):
      return conn.map(const(signedUpSuccessfully))
        |> homeResponse

    case let .invite(.accept(inviteId)):
      return conn.map(const(inviteId))
        |> acceptInviteMiddleware

    case let .invite(.resend(inviteId)):
      return conn.map(const(inviteId))
        |> resendInviteMiddleware

    case let .invite(.revoke(inviteId)):
      return conn.map(const(inviteId))
        |> revokeInviteMiddleware

    case let .invite(.send(email)):
      return conn.map(const(email))
        |> sendInviteMiddleware

    case let .invite(.show(inviteId)):
      return conn.map(const(inviteId))
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

    case .paymentInfo:
      return conn.map(const(unit))
        |> paymentInfoResponse

    case let .pricing(plan, quantity):
      let pricing: Pricing
      if let quantity = quantity {
        pricing = .team(quantity)
      } else if let plan = plan, let billing = Pricing.Billing(rawValue: plan) {
        pricing = .individual(billing)
      } else {
        pricing = .default
      }

      return conn.map(const((pricing, user, route)))
        |> pricingResponse

    case .secretHome:
      return conn.map(const(unit))
        |> secretHomeResponse

    case let .subscribe(data):
      return conn.map(const(data))
        |> subscribeResponse

    case .team(.show):
      return conn.map(const(unit))
        |> teamResponse

    case let .team(.remove(teammateId)):
      return conn.map(const(teammateId))
        |> removeTeammateMiddleware

    case .terms:
      return conn.map(const(unit))
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
       .account,
       .episode,
       .gitHubCallback,
       .invite(.accept),
       .invite(.resend),
       .invite(.revoke),
       .invite(.send),
       .invite(.show),
       .login,
       .logout,
       .paymentInfo,
       .pricing,
       .secretHome,
       .subscribe,
       .team(.show),
       .team(.remove),
       .terms:

    return true

  case .home,
       .launchSignup:
    
    return false
  }
}
