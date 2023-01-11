import Dependencies
import Either
import Foundation
import HttpPipeline
import Logging
import LoggingDependencies
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tuple
import Views

public func siteMiddleware(
  _ conn: Conn<StatusLineOpen, Prelude.Unit>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
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
  if conn.request.allHTTPHeaderFields?["X-Forwarded-Proto"] != .some("https"),
    let url = conn.request.url,
    !allowedInsecureHosts.contains(url.host ?? ""),
    let secureURL = makeHttps(url: url)
  {
    return await redirect(to: secureURL.absoluteString, status: .movedPermanently)(conn)
      .performAsync()
  }

  // Early out to canonicalize host
  if let url = conn.request.url,
    !isAllowed(host: url.host ?? ""),
    let canonicalURL = canonicalizeHost(url: url)
  {
    return await redirect(to: canonicalURL.absoluteString, status: .movedPermanently)(conn)
      .performAsync()
  }

  let currentUser: Models.User?
  if let userID = conn.request.session.userId {
    await fireAndForget { try await database.sawUser(userID) }
    currentUser = try? await database.fetchUserById(userID)
  } else {
    currentUser = nil
  }

  let subscription = try? await database.fetchSubscription(user: currentUser.unwrap())
  let enterpriseAccount =
    try? await database
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
    $0.requestID = requestID
    $0.currentRoute = siteRoute ?? .home
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
    return await render(conn: conn)
  }
}

private func render(conn: Conn<StatusLineOpen, Prelude.Unit>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.currentRoute) var route
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  switch route {
  case .about:
    return aboutResponse(conn.map { _ in () })

  case let .account(account):
    return await accountMiddleware(conn: conn.map(const(account)))
      .performAsync()

  case let .admin(route):
    return await adminMiddleware(conn: conn.map(const(route)))
      .performAsync()

  case let .api(apiRoute):
    return await apiMiddleware(conn.map(const(apiRoute)))
      .performAsync()

  case .appleDeveloperMerchantIdDomainAssociation:
    return await appleDeveloperMerchantIdDomainAssociationMiddleware(conn.map(const(unit)))
      .performAsync()

  case let .blog(subRoute):
    return await blogMiddleware(conn: conn.map(const(subRoute)))
      .performAsync()

  case .collections(.index):
    return await collectionsIndexMiddleware(conn.map(const(())))
      .performAsync()

  case let .collections(.collection(slug, .show)):
    return await collectionMiddleware(conn.map(const(slug)))
      .performAsync()

  case let .collections(.collection(collectionSlug, .section(sectionSlug, .show))):
    return await collectionSectionMiddleware(
      conn.map(const(collectionSlug .*. sectionSlug .*. unit))
    )
    .performAsync()

  case let .collections(.collection(collectionSlug, .section(_, .episode(episodeParam)))):
    return await episodeResponse(conn.map(const(episodeParam .*. collectionSlug .*. unit)))
      .performAsync()

  case let .discounts(couponId, billing):
    let subscribeData = SubscribeConfirmationData(
      billing: billing ?? .yearly,
      isOwnerTakingSeat: true,
      referralCode: nil,
      teammates: [],
      useRegionalDiscount: false
    )
    return await discountSubscribeConfirmation(
      conn.map(const(.personal .*. subscribeData .*. couponId .*. unit))
    )
    .performAsync()

  case .endGhosting:
    return await endGhostingMiddleware(conn.map(const(unit)))
      .performAsync()

  case .episode(.index):
    return await redirect(to: siteRouter.path(for: .home))(conn)
      .performAsync()

  case let .episode(.progress(param: param, percent: percent)):
    return await progressResponse(conn.map(const(param .*. percent .*. unit)))
      .performAsync()

  case let .episode(.show(param)):
    return await episodeResponse(conn.map(const(param .*. nil .*. unit)))
      .performAsync()

  case let .enterprise(domain, .acceptInvite(encryptedEmail, encryptedUserId)):
    return await enterpriseAcceptInviteMiddleware(
      conn.map(const(currentUser .*. domain .*. encryptedEmail .*. encryptedUserId .*. unit))
    )
    .performAsync()

  case let .enterprise(domain, .landing):
    return await enterpriseLandingResponse(conn.map(const(domain)))
      .performAsync()

  case let .enterprise(domain, .requestInvite(request)):
    return await enterpriseRequestMiddleware(conn.map(const(domain .*. request .*. unit)))
      .performAsync()

  case let .expressUnsubscribe(payload):
    return await expressUnsubscribeMiddleware(conn.map(const(payload)))
      .performAsync()

  case let .expressUnsubscribeReply(payload):
    return await expressUnsubscribeReplyMiddleware(conn.map(const(payload)))
      .performAsync()

  case .feed(.atom), .feed(.episodes):
    @Dependency(\.envVars.emergencyMode) var emergencyMode
    guard !emergencyMode
    else {
      return
        conn
        .writeStatus(.internalServerError)
        .respond(json: "{}")
    }
    return episodesRssMiddleware(conn.map { _ in })

  case let .gifts(giftsRoute):
    return await giftsMiddleware(conn.map(const(giftsRoute)))
      .performAsync()

  case let .gitHubCallback(code, redirect):
    return await gitHubCallbackResponse(conn.map(const(code .*. redirect .*. unit)))
      .performAsync()

  case .home:
    return await homeMiddleware(conn.map(const(())))
      .performAsync()

  case let .invite(.addTeammate(email)):
    return await addTeammateViaInviteMiddleware(conn.map(const(currentUser .*. email .*. unit)))
      .performAsync()

  case let .invite(.invitation(inviteId, .accept)):
    return await acceptInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case let .invite(.invitation(inviteId, .resend)):
    return await resendInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case let .invite(.invitation(inviteId, .revoke)):
    return await revokeInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case let .invite(.invitation(inviteId, .show)):
    return await showInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case let .invite(.send(email)):
    return await sendInviteMiddleware(conn.map(const(email .*. currentUser .*. unit)))
      .performAsync()

  case let .login(redirect):
    return await loginResponse(conn.map(const(redirect)))
      .performAsync()

  case .logout:
    return await logoutResponse(conn.map(const(unit)))
      .performAsync()

  case .pricingLanding:
    return await pricingLanding(conn.map(const(())))
      .performAsync()

  case .privacy:
    return await privacyResponse(conn.map(const(())))
      .performAsync()

  case let .subscribe(data):
    return await subscribeMiddleware(conn.map(const(currentUser .*. data .*. unit)))
      .performAsync()

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
    return await subscribeConfirmation(
      conn.map(const(lane .*. subscribeData .*. nil .*. unit))
    )
    .performAsync()

  case let .team(.join(teamInviteCode, .landing)):
    return await joinTeamLandingMiddleware(conn.map(const(teamInviteCode)))
      .performAsync()

  case let .team(.join(teamInviteCode, .confirm)):
    return await joinTeamMiddleware(conn.map(const(teamInviteCode)))
      .performAsync()

  case .team(.leave):
    return await leaveTeamMiddleware(conn.map(const(currentUser .*. subscriberState .*. unit)))
      .performAsync()

  case let .team(.remove(teammateId)):
    return await removeTeammateMiddleware(conn.map(const(teammateId .*. currentUser .*. unit)))
      .performAsync()

  case let .useEpisodeCredit(episodeId):
    return await useCreditResponse(
      conn: conn.map(
        const(Either.right(episodeId) .*. currentUser .*. subscriberState .*. route .*. unit)
      )
    )
    .performAsync()

  case let .webhooks(.stripe(.paymentIntents(event))):
    return await stripePaymentIntentsWebhookMiddleware(conn.map(const(event)))
      .performAsync()

  case let .webhooks(.stripe(.subscriptions(event))):
    return await stripeSubscriptionsWebhookMiddleware(conn.map(const(event)))
      .performAsync()

  case let .webhooks(.stripe(.unknown(event))):
    @Dependency(\.logger) var logger: Logger
    logger.log(.error, "Received invalid webhook \(event.type)")
    return
      conn
      .writeStatus(.internalServerError)
      .respond(text: "We don't support this event.")

  case .webhooks(.stripe(.fatal)):
    return
      conn
      .writeStatus(.internalServerError)
      .respond(text: "We don't support this event.")
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
private let allowedHosts: [String] = {
  @Dependency(\.envVars.baseUrl.host) var host
  return [
    canonicalHost,
    host,
    "127.0.0.1",
    "0.0.0.0",
    "localhost",
  ]
  .compactMap { $0 }
}()

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
