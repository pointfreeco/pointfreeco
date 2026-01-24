import Dependencies
import Either
import Foundation
import Ghosting
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
  @Dependency(\.envVars) var envVars
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
    await fireAndForget { try await database.sawUser(id: userID) }
    currentUser = try? await database.fetchUser(id: userID)
  } else {
    currentUser = nil
  }

  let subscription = try? await database.fetchSubscription(user: currentUser.unwrap())
  let enterpriseAccount =
    try? await database
    .fetchEnterpriseAccountForSubscription(subscription.unwrap().id)

  let progresses =
    (try? await database.fetchEpisodeProgresses(userID: currentUser.unwrap().id))
    ?? []
  let livestreams = (try? await database.fetchLivestreams()) ?? []

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
    $0.currentRoute = siteRoute ?? .home
    $0.episodeProgresses = [Episode.Sequence: EpisodeProgress](
      progresses.map { ($0.episodeSequence, $0) },
      uniquingKeysWith: { $1 }
    )
    $0.isGhosting = conn.request.session.ghosteeId != nil
    $0.livestreams = livestreams
    $0.requestID = requestID
    $0.subscriberState = SubscriberState(
      user: currentUser,
      subscription: subscription,
      enterpriseAccount: enterpriseAccount
    )
    $0.subscription = subscription
    if let ownerUserID = subscription?.userId {
      $0.subscriptionOwner = try? await database.fetchUser(id: ownerUserID)
    }
  } operation: {
    // Early out if route cannot be matched
    guard siteRoute != nil
    else { return routeNotFoundMiddleware(conn) }
    return await render(conn: conn.map { _ in })
  }
}

private func render(conn: Conn<StatusLineOpen, Void>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.currentRoute) var route
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  switch route {
  case .about:
    return aboutResponse(conn)

  case .theWay:
    return pointFreeWayMiddleware(conn)

  case .account(let account):
    return await accountMiddleware(conn: conn.map(const(account)))
      .performAsync()

  case .admin(let route):
    return await adminMiddleware(conn, route: route)

  case .api(let apiRoute):
    return await apiMiddleware(conn.map(const(apiRoute)))
      .performAsync()

  case .wellKnown(let route):
    return await wellKnown(route: route, conn: conn)

  case .auth(let route):
    return await authMiddleware(conn, route: route)

  case .blog(let route):
    return blogMiddleware(conn, route: route)

  case .clips(let clipsRoute):
    return await clipsMiddleware(conn.map(const(clipsRoute)))

  case .collections(.index):
    return await collectionsIndexMiddleware(conn)

  case .collections(.collection(let slug, .show)):
    return await collectionMiddleware(conn.map(const(slug)))
      .performAsync()

  case .collections(.collection(let collectionSlug, .section(let sectionSlug, .show))):
    return await collectionSectionMiddleware(
      conn.map(const(collectionSlug .*. sectionSlug .*. unit))
    )
    .performAsync()

  case .collections(.collection(let collectionSlug, .section(_, .episode(let episodeParam)))):
    return await episodesMiddleware(
      route: .episode(param: episodeParam, .show(collection: collectionSlug)),
      conn
    )

  case .collections(.collection(_, .section(_, .progress(let episodeParam, let percent)))):
    return await episodesMiddleware(
      route: .episode(param: episodeParam, .progress(percent: percent)),
      conn
    )

  case .discounts(let couponId, let billing):
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
    return endGhostingMiddleware(conn)

  case .episodes(let route):
    return await episodesMiddleware(route: route, conn)

  case .enterprise(let domain, .acceptInvite(let encryptedEmail, let encryptedUserId)):
    return await enterpriseAcceptInviteMiddleware(
      conn.map(const(currentUser .*. domain .*. encryptedEmail .*. encryptedUserId .*. unit))
    )
    .performAsync()

  case .enterprise(let domain, .landing):
    return await enterpriseLandingResponse(conn.map(const(domain)))
      .performAsync()

  case .enterprise(let domain, .requestInvite(let request)):
    return await enterpriseRequestMiddleware(conn.map(const(domain .*. request .*. unit)))
      .performAsync()

  case .expressUnsubscribe(let payload):
    return await expressUnsubscribeMiddleware(conn, payload: payload)

  case .expressUnsubscribeReply(let payload):
    return await expressUnsubscribeReplyMiddleware(conn, payload: payload)

  case .feed(let feedRoute):
    @Dependency(\.envVars.emergencyMode) var emergencyMode
    guard !emergencyMode
    else {
      return
        conn
        .writeStatus(.internalServerError)
        .respond(json: "{}")
    }

    switch feedRoute {
    case .atom, .episodes:
      return episodesRssMiddleware(conn)
    case .slack:
      return slackEpisodesRssMiddleware(conn)
    }

  case .gifts(let giftsRoute):
    return await giftsMiddleware(conn.map(const(giftsRoute)))
      .performAsync()

  case .home:
    return await homeMiddleware(conn.map(const(())))

  case .invite(.addTeammate(let email)):
    return await addTeammateViaInviteMiddleware(conn.map(const(currentUser .*. email .*. unit)))
      .performAsync()

  case .invite(.invitation(let inviteId, .accept)):
    return await acceptInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case .invite(.invitation(let inviteId, .resend)):
    return await resendInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case .invite(.invitation(let inviteId, .revoke)):
    return await revokeInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case .invite(.invitation(let inviteId, .show)):
    return await showInviteMiddleware(conn.map(const(inviteId .*. currentUser .*. unit)))
      .performAsync()

  case .invite(.send(let email)):
    return await sendInviteMiddleware(conn.map(const(email .*. currentUser .*. unit)))
      .performAsync()

  case .teamInviteCode(let joinRoute):
    return await joinMiddleware(conn, route: joinRoute)

  case .live(let liveRoute):
    return liveMiddleware(conn, route: liveRoute)

  case .pricingLanding:
    return pricingMiddleware(conn)

  case .privacy:
    return privacyMiddleware(conn)

  case .resume:
    return await resumeMiddleware(conn)

  case .robots:
    return
      conn
      .writeStatus(.ok)
      .respond(
        text: """
          User-Agent: *
          Disallow: /account

          #User-Agent: GPTBot
          #Disallow: /
          """
      )

  case .slackInvite:
    @Dependency(\.envVars) var envVars
    return await conn.redirect(to: envVars.slackInviteURL)

  case .subscribe(let data):
    return await subscribeMiddleware(conn.map(const(currentUser .*. data .*. unit)))
      .performAsync()

  case .subscribeConfirmation(
    let
      lane,
    let billing,
    let isOwnerTakingSeat,
    let teammates,
    let referralCode,
    let useRegionalDiscount
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

  case .team(.join(let teamInviteCode, .landing)):
    return joinTeamLandingMiddleware(conn, inviteCode: teamInviteCode)

  case .team(.join(let teamInviteCode, .confirm)):
    return joinTeamMiddleware(conn, inviteCode: teamInviteCode)

  case .team(.leave):
    return await leaveTeamMiddleware(
      conn,
      currentUser: currentUser,
      subscriberState: subscriberState
    )

  case .team(.remove(let teammateId)):
    return await removeTeammateMiddleware(
      conn,
      teammateID: teammateId,
      currentUser: currentUser
    )

  case .webhooks(.stripe(.paymentIntents(let event))):
    return await stripePaymentIntentsWebhookMiddleware(conn, event: event)

  case .webhooks(.stripe(.subscriptions(let event))):
    return await stripeSubscriptionsWebhookMiddleware(conn, event: event)

  case .webhooks(.stripe(.unknown(let event))):
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
    headersMiddleware: (Conn<HeadersOpen, A>) async -> Conn<HeadersOpen, A>
  ) async -> Conn<ResponseEnded, Data> {
    @Dependency(\.siteRouter) var siteRouter

    return await self.redirect(
      to: siteRouter.path(for: route),
      headersMiddleware: headersMiddleware
    )
  }

  public func redirect(
    with route: (A) -> SiteRoute,
    headersMiddleware: (Conn<HeadersOpen, A>) async -> Conn<HeadersOpen, A>
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
