import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tuple
import Views

public let siteMiddleware = { conn in
  IO { await _siteMiddleware(conn) }
}

private func _siteMiddleware(
  _ conn: Conn<StatusLineOpen, Prelude.Unit>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.logger) var logger
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.uuid) var uuid

  // Perform logging for each request
  let requestID = uuid()
  let startTime = Date().timeIntervalSince1970
  logger.log(
    .info,
        """
        \(requestID) [Request] \(conn.request.httpMethod ?? "GET") \
        \(conn.request.url?.relativePath ?? "")
        """
  )
  defer {
    let endTime = Date().timeIntervalSince1970
    logger.log(.info, "\(requestID) [Time] \(Int((endTime - startTime) * 1000))ms")
  }

  // Early out to force HTTPS
  if
    conn.request.allHTTPHeaderFields?["X-Forwarded-Proto"] != .some("https"),
    let url = conn.request.url,
    !allowedInsecureHosts.contains(url.host ?? ""),
    let secureURL = makeHttps(url: url)
  {
    return await redirect(to: secureURL.absoluteString, status: .movedPermanently)(conn)
      .performAsync()
  }

  // Early out to canonicalize host
  if
    let url = conn.request.url,
    !isAllowed(host: url.host ?? ""),
    let canonicalURL = canonicalizeHost(url: url)
  {
    return await redirect(to: canonicalURL.absoluteString, status: .movedPermanently)(conn)
      .performAsync()
  }

  let currentUser: Models.User?
  if let userID = conn.request.session.userId {
    await fireAndForget { try await Current.database.sawUser(userID) }
    currentUser = try? await Current.database.fetchUserById(userID)
  } else {
    currentUser = nil
  }

  let subscription = try? await Current.database.fetchSubscription(user: currentUser.unwrap())
  let enterpriseAccount = try? await Current.database
    .fetchEnterpriseAccountForSubscription(subscription.unwrap().id)

  let siteRoute: SiteRoute?
  do {
    siteRoute = try siteRouter.match(request: conn.request)
  } catch {
#if DEBUG
    print(error)
#endif
    siteRoute = nil
  }

  return await withDependencies {
    $0.currentUser = currentUser
    $0.enterpriseAccount = enterpriseAccount
    $0.requestID = requestID
    $0.siteRoute = siteRoute ?? .home
    $0.subscriberState = SubscriberState(
      user: currentUser,
      subscription: subscription,
      enterpriseAccount: enterpriseAccount
    )
    $0.subscription = subscription
  } operation: {
    // Early out if route cannot be matched
    guard siteRoute != nil
    else { return await routeNotFoundMiddleware(conn).performAsync() }

    return await render(conn: conn).performAsync()
  }
}

private func render(conn: Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRoute) var route
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  switch route {
  case .about:
    return pure(aboutResponse(conn.map { _ in () }))

  case let .account(account):
    return conn.map(const(account))
    |> accountMiddleware

  case let .admin(route):
    return conn.map(const(route))
    |> adminMiddleware

  case let .api(apiRoute):
    return conn.map(const(apiRoute))
    |> apiMiddleware

  case .appleDeveloperMerchantIdDomainAssociation:
    return conn.map(const(unit))
    |> appleDeveloperMerchantIdDomainAssociationMiddleware

  case let .blog(subRoute):
    return conn.map(const(subRoute))
    |> blogMiddleware

  case .collections(.index):
    return conn.map(const(()))
    |> collectionsIndexMiddleware

  case let .collections(.collection(slug, .show)):
    return conn.map(const(slug))
    |> collectionMiddleware

  case let .collections(.collection(collectionSlug, .section(sectionSlug, .show))):
    return conn.map(const(collectionSlug .*. sectionSlug .*. unit))
    |> collectionSectionMiddleware

  case let .collections(.collection(collectionSlug, .section(_, .episode(episodeParam)))):
    return
    conn
      .map(const(episodeParam .*. collectionSlug .*. unit))
    |> episodeResponse

  case let .discounts(couponId, billing):
    let subscribeData = SubscribeConfirmationData(
      billing: billing ?? .yearly,
      isOwnerTakingSeat: true,
      referralCode: nil,
      teammates: [],
      useRegionalDiscount: false
    )
    return conn.map(const(.personal .*. subscribeData .*. couponId .*. unit))
    |> discountSubscribeConfirmation

  case .endGhosting:
    return conn.map(const(unit))
    |> endGhostingMiddleware

  case .episode(.index):
    return conn
    |> redirect(to: siteRouter.path(for: .home))

  case let .episode(.progress(param: param, percent: percent)):
    return conn.map(const(param .*. percent .*. unit))
    |> progressResponse

  case let .episode(.show(param)):
    return conn.map(const(param .*. nil .*. unit))
    |> episodeResponse

  case let .enterprise(domain, .acceptInvite(encryptedEmail, encryptedUserId)):
    return conn.map(const(currentUser .*. domain .*. encryptedEmail .*. encryptedUserId .*. unit))
    |> enterpriseAcceptInviteMiddleware

  case let .enterprise(domain, .landing):
    return conn.map(const(domain))
    |> enterpriseLandingResponse

  case let .enterprise(domain, .requestInvite(request)):
    return conn.map(const(domain .*. request .*. unit))
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
    return conn.map(const(giftsRoute))
    |> giftsMiddleware

  case let .gitHubCallback(code, redirect):
    return conn.map(const(code .*. redirect .*. unit))
    |> gitHubCallbackResponse

  case .home:
    return conn.map(const(()))
    |> homeMiddleware

  case let .invite(.addTeammate(email)):
    return conn.map(const(currentUser .*. email .*. unit))
    |> addTeammateViaInviteMiddleware

  case let .invite(.invitation(inviteId, .accept)):
    return conn.map(const(inviteId .*. currentUser .*. unit))
    |> acceptInviteMiddleware

  case let .invite(.invitation(inviteId, .resend)):
    return conn.map(const(inviteId .*. currentUser .*. unit))
    |> resendInviteMiddleware

  case let .invite(.invitation(inviteId, .revoke)):
    return conn.map(const(inviteId .*. currentUser .*. unit))
    |> revokeInviteMiddleware

  case let .invite(.invitation(inviteId, .show)):
    return conn.map(const(inviteId .*. currentUser .*. unit))
    |> showInviteMiddleware

  case let .invite(.send(email)):
    return conn.map(const(email .*. currentUser .*. unit))
    |> sendInviteMiddleware

  case let .login(redirect):
    return conn.map(const(redirect))
    |> loginResponse

  case .logout:
    return conn.map(const(unit))
    |> logoutResponse

  case .pricingLanding:
    return conn.map(const(()))
    |> pricingLanding

  case .privacy:
    return conn.map(const(()))
    |> privacyResponse

  case let .subscribe(data):
    return conn.map(const(currentUser .*. data .*. unit))
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
      const(lane .*. subscribeData .*. nil .*. unit))
    |> subscribeConfirmation

  case let .team(.join(teamInviteCode, .landing)):
    return conn.map(const(subscriberState .*. teamInviteCode .*. unit))
    |> joinTeamLandingMiddleware

  case let .team(.join(teamInviteCode, .confirm)):
    return conn.map(const(subscriberState .*. teamInviteCode .*. unit))
    |> joinTeamMiddleware

  case .team(.leave):
    return conn.map(const(currentUser .*. subscriberState .*. unit))
    |> leaveTeamMiddleware

  case let .team(.remove(teammateId)):
    return conn.map(const(teammateId .*. currentUser .*. unit))
    |> removeTeammateMiddleware

  case let .useEpisodeCredit(episodeId):
    return conn.map(const(Either.right(episodeId) .*. currentUser .*. subscriberState .*. route .*. unit))
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

private func makeHttps(url: URL) -> URL? {
  var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
  components?.scheme = "https"
  return components?.url
}

private func canonicalizeHost(url: URL) -> URL? {
  var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
  components?.host = canonicalHost
  return components?.url
}
