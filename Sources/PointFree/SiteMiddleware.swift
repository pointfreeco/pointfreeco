import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import Styleguide
import Tuple

public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requestLogger { Current.logger.info($0) }
    <<< responseTimeout(25)
    <<< requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(isAllowedHost: isAllowed(host:), canonicalHost: canonicalHost)
    <<< route(router: router, notFound: routeNotFoundMiddleware)
    <| currentUserMiddleware
    >=> currentSubscriptionMiddleware
    >=> render(conn:)

private func render(conn: Conn<StatusLineOpen, T3<Database.Subscription?, Database.User?, Route>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscription, user, route) = (conn.data.first, conn.data.second.first, conn.data.second.second)
    let subscriberState = SubscriberState(user: user, subscription: subscription)

    switch route {
    case .about:
      return conn.map(const(user .*. subscriberState .*. route .*. unit))
        |> aboutResponse

    case let .account(.confirmEmailChange(userId, emailAddress)):
      return conn.map(const(userId .*. emailAddress .*. unit))
        |> confirmEmailChangeMiddleware

    case .account(.index):
      return conn.map(const(user .*. subscriberState .*. unit))
        |> accountResponse

    case .account(.invoices(.index)):
      return conn.map(const(user .*. subscriberState .*. unit))
        |> invoicesResponse

    case let .account(.invoices(.show(invoiceId))):
      return conn.map(const(user .*. invoiceId .*. unit))
        |> invoiceResponse

    case let .account(.paymentInfo(.show(expand))):
      return conn.map(const(user .*. (expand ?? false) .*. subscriberState .*. unit))
        |> paymentInfoResponse

    case let .account(.paymentInfo(.update(token))):
      return conn.map(const(user .*. token .*. unit))
        |> updatePaymentInfoMiddleware

    case .account(.subscription(.cancel)):
      return conn.map(const(user .*. unit))
        |> cancelMiddleware

    case .account(.subscription(.change(.show))):
      return conn.map(const(user .*. subscriberState .*. unit))
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

    case let .admin(.newBlogPostEmail(.send(blogPost, subscriberAnnouncement, nonSubscriberAnnouncement, isTest))):
      return conn.map(const(user .*. blogPost .*. subscriberAnnouncement .*. nonSubscriberAnnouncement .*. isTest .*. unit))
        |> sendNewBlogPostEmailMiddleware

    case .admin(.newBlogPostEmail(.index)):
      return conn.map(const(user .*. unit))
        |> showNewBlogPostEmailMiddleware

    case let .admin(.newEpisodeEmail(.send(episodeId, subscriberAnnouncement, nonSubscriberAnnouncement, isTest))):
      return conn.map(const(user .*. episodeId .*. subscriberAnnouncement .*. nonSubscriberAnnouncement .*. isTest .*. unit))
        |> sendNewEpisodeEmailMiddleware

    case .admin(.newEpisodeEmail(.show)):
      return conn.map(const(user .*. unit))
        |> showNewEpisodeEmailMiddleware

    case .appleDeveloperMerchantIdDomainAssociation:
      return conn.map(const(unit))
        |> appleDeveloperMerchantIdDomainAssociationMiddleware

    case let .blog(subRoute):
      return conn.map(const(user .*. subscriberState .*. route .*. subRoute .*. unit))
        |> blogMiddleware

    case let .episode(param):
      return conn.map(const(param .*. user .*. subscriberState .*. route .*. unit))
        |> episodeResponse

    case .episodes:
      return conn
        |> redirect(to: path(to: .home))

    case let .expressUnsubscribe(userId, newsletter):
      return conn.map(const(userId .*. newsletter .*. unit))
        |> expressUnsubscribeMiddleware

    case let .expressUnsubscribeReply(payload):
      return conn.map(const(payload))
        |> expressUnsubscribeReplyMiddleware

    case .feed(.atom):
      return conn.map(const(Current.episodes()))
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
      return conn.map(const(user .*. subscriberState .*. route .*. unit))
        |> privacyResponse

    case .home:
      return conn.map(const(user .*. subscriberState .*. route .*. unit))
        |> homeMiddleware

    case let .subscribe(data):
      return conn.map(const(data .*. user .*. unit))
        |> subscribeMiddleware

    case .team(.leave):
      return conn.map(const(user .*. subscriberState .*. unit))
        |> leaveTeamMiddleware

    case let .team(.remove(teammateId)):
      return conn.map(const(teammateId .*. user .*. unit))
        |> removeTeammateMiddleware

    case let .useEpisodeCredit(episodeId):
      return conn.map(const(Either.right(episodeId.rawValue) .*. user .*. subscriberState .*. route .*. unit))
        |> useCreditResponse

    case let .webhooks(.stripe(.invoice(event))):
      return conn.map(const(event))
        |> stripeInvoiceWebhookMiddleware

    case .webhooks(.stripe(.fallthrough)):
      return conn
        |> writeStatus(.internalServerError)
        >=> respond(text: "We don't support this event.")
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

enum SubscriberState {
  case nonSubscriber
  case owner(hasSeat: Bool, status: Stripe.Subscription.Status)
  case teammate(status: Stripe.Subscription.Status)

  init(user: Database.User?, subscription: Database.Subscription?) {
    switch (user, subscription) {
    case let (.some(user), .some(subscription)):
      if subscription.userId == user.id {
        self = .owner(
          hasSeat: user.subscriptionId != nil,
          status: subscription.stripeSubscriptionStatus
        )
      } else {
        self = .teammate(status: subscription.stripeSubscriptionStatus)
      }

    case (.none, _), (.some, _):
      self = .nonSubscriber
    }
  }

  var status: Stripe.Subscription.Status? {
    switch self {
    case .nonSubscriber:
      return nil
    case let .owner(_, status):
      return status
    case let .teammate(status):
      return status
    }
  }

  var isActive: Bool {
    return self.status == .some(.active)
  }

  var isPastDue: Bool {
    return self.status == .some(.pastDue)
  }

  var isOwner: Bool {
    if case .owner = self { return true }
    return false
  }

  var isTeammate: Bool {
    if case .teammate = self { return true }
    return false
  }

  var isNonSubscriber: Bool {
    if case .nonSubscriber = self { return true }
    return false
  }

  var isActiveSubscriber: Bool {
    if case .teammate(status: .active) = self { return true }
    if case .owner(hasSeat: true, status: .active) = self { return true }
    return false
  }
}
