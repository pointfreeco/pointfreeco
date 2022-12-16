import Either
import Foundation
import Html
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Syndication
import Tuple

let accountRssMiddleware =
  fetchUserByRssSalt
  <<< requireUser
  <<< { trackFeedRequest(userId: \.first.id) >=> $0 }
  <<< validateUserAgent
  <<< fetchActiveStripeSubscription
  <| map(lower)
  >>> accountRssResponse

private let fetchActiveStripeSubscription: MT<Tuple1<User>, Tuple2<Stripe.Subscription?, User>> =
  fetchUserSubscription
  <<< requireSubscriptionNotDeactivated
  <<< requireActiveSubscription
  <<< fetchStripeSubscriptionForUser

private func requireUser(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple1<User>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple1<User?>, Data> {
  return middleware
    |> filterMap(
      require1 >>> pure,
      or: invalidatedFeedMiddleware(
        errorMessage: """
          ‼️ The URL for this feed has been turned off by Point-Free due to suspicious activity. You can \
          retrieve your most up-to-date private podcast URL by visiting your account page at \
          \(siteRouter.url(for: .account())). If you think this is an error, please contact support@pointfree.co.
          """)
    )
}

private let requireSubscriptionNotDeactivated:
  (
    @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<Models.Subscription?, User>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<Models.Subscription?, User>, Data> =
    filter(
      { get1($0)?.deactivated != .some(true) },
      or: invalidatedFeedMiddleware(
        errorMessage: """
          ‼️ Your subscription has been deactivated. Please contact us at support@pointfree.co to regain access \
          to Point-Free.
          """)
    )

private let requireActiveSubscription:
  (
    @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple1<User>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<Models.Subscription?, User>, Data> =
    filterMap(
      validateActiveSubscriber,
      or: invalidatedFeedMiddleware(
        errorMessage: """
          ‼️ The URL for this feed has been turned off by Point-Free as the associated subscription is no longer \
          active. If you would like reactive this feed you can resubscribe to Point-Free on your account page at \
          \(siteRouter.url(for: .account())). If you think this is an error, please contact support@pointfree.co.
          """)
    )

private let accountRssResponse:
  Middleware<StatusLineOpen, ResponseEnded, (Stripe.Subscription?, User), Data> =
    writeStatus(.ok)
    >=> respond(privateEpisodesFeedView, contentType: .text(.init(rawValue: "xml"), charset: .utf8))
    >=> clearHeadBody

private func invalidatedFeedMiddleware<A>(errorMessage: String) -> (Conn<StatusLineOpen, A>) -> IO<
  Conn<ResponseEnded, Data>
> {
  return { conn in
    conn.map(const(errorMessage))
      |> writeStatus(.ok)
      >=> respond(invalidatedFeedView, contentType: .text(.init(rawValue: "xml"), charset: .utf8))
      >=> clearHeadBody
  }
}

private func fetchUserByRssSalt(
  _ middleware: (@escaping Middleware<StatusLineOpen, ResponseEnded, Tuple1<User?>, Data>)
)
  -> Middleware<StatusLineOpen, ResponseEnded, Tuple1<User.RssSalt>, Data>
{
  return { conn in
    Current.database.fetchUserByRssSalt(get1(conn.data))
      .run
      .map { conn.map(const($0.right.flatMap(id) .*. unit)) }
      .flatMap(middleware)
  }
}

private func validateActiveSubscriber<Z>(
  data: T3<Models.Subscription?, User, Z>
) -> IO<T2<User, Z>?> {

  return IO {
    guard let subscription = get1(data) else { return nil }
    let user = get2(data)

    return SubscriberState(user: user, subscriptionAndEnterpriseAccount: (subscription, nil))
      .isActive
      ? user .*. rest(data)
      : nil
  }
}

private func validateUserAgent<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<User, Z>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, T2<User, Z>, Data> {
  return { conn in
    let user = get1(conn.data)

    guard
      let userAgent = conn.request.allHTTPHeaderFields?["User-Agent"]?.lowercased(),
      Current.envVars.rssUserAgentWatchlist.contains(where: { userAgent.contains($0) })
    else { return middleware(conn) }

    return Current.database.updateUser(
      id: user.id,
      rssSalt: User.RssSalt(
        rawValue: Current.uuid().uuidString.lowercased()
      )
    )
    .flatMap { _ in
      sendInvalidRssFeedEmail(user: user, userAgent: userAgent)
        .withExcept { $0 as Error }
    }
    .run
    .flatMap { _ in
      conn
        |> invalidatedFeedMiddleware(
          errorMessage: """
            ‼️ The URL for this feed has been turned off by Point-Free due to suspicious activity. You can \
            retrieve your most up-to-date private podcast URL by visiting your account page at \
            \(siteRouter.url(for: .account())). If you think this is an error, please contact support@pointfree.co.
            """)
    }
  }
}

private func trackFeedRequest<A, I>(
  userId: @escaping (A) -> User.ID
)
  -> (Conn<I, A>) -> IO<Conn<I, A>>
{

  return { conn in
    IO {
      do {
        try await Current.database.createFeedRequestEvent(
          .privateEpisodesFeed,
          conn.request.allHTTPHeaderFields?["User-Agent"] ?? "",
          userId(conn.data)
        )
      } catch {
        notifyError(error, subject: "Create Feed Request Event Failed")
      }
      return conn
    }
  }
}

private func fetchStripeSubscriptionForUser<A>(
  _ middleware: (
    @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription?, User, A>, Data>
  )
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{

  return { conn in
    EitherIO {
      try await requireSome(
        Current.database.fetchSubscriptionById(requireSome(conn.data.first.subscriptionId))
      )
    }
    .flatMap(Current.stripe.fetchSubscription <<< \.stripeSubscriptionId)
    .run
    .map(\.right)
    .flatMap { conn.map(const($0 .*. conn.data)) |> middleware }
  }
}

private let privateEpisodesFeedView = itunesRssFeedLayout {
  (data: (subscription: Stripe.Subscription?, user: User)) -> Node in
  node(
    rssChannel: privateRssChannel(user: data.user),
    items: items(forUser: data.user, subscription: data.subscription)
  )
}

func privateRssChannel(user: User) -> RssChannel {
  let description = """
    Point-Free is a video series about functional programming and the Swift programming language. Each episode
    covers a topic that may seem complex and academic at first, but turns out to be quite simple. At the end of
    each episode we’ll ask “what’s the point?!”, so that we can bring the concepts back down to earth and show
    how these ideas can improve the quality of your code today.

    ---

    This is a private feed associated with the Point-Free account \(user.email). Please do not share this link
    with anyone else.
    """
  let title = "Point-Free Videos (Private feed for \(user.email.rawValue))"

  return RssChannel(
    copyright:
      "Copyright Point-Free, Inc. \(Calendar.current.component(.year, from: Current.date()))",
    description: description,
    image: .init(
      link: siteRouter.url(for: .home),
      title: title,
      url: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"
    ),
    itunes: .init(
      author: "Brandon Williams & Stephen Celis",
      block: .yes,
      categories: [
        .init(name: "Technology", subcategory: "Software How-To"),
        .init(name: "Education", subcategory: "Training"),
      ],
      explicit: false,
      keywords: [
        "programming",
        "development",
        "mobile",
        "ios",
        "functional",
        "swift",
        "apple",
        "developer",
        "software engineering",
        "server",
        "app",
      ],
      image: .init(
        href: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"),
      owner: .init(email: "support@pointfree.co", name: "Brandon Williams & Stephen Celis"),
      subtitle: "Functional programming concepts explained simply.",
      summary: description,
      type: .episodic
    ),
    language: "en-US",
    link: siteRouter.url(for: .home),
    title: title
  )
}

let nonYearlyMaxRssItems = 4

private func items(forUser user: User, subscription: Stripe.Subscription?) -> [RssItem] {
  return
    Current
    .episodes()
    .filter { $0.sequence != 0 }
    .sorted(by: their(\.sequence, >))
    .prefix(subscription?.plan.interval == .some(.year) ? 99999 : nonYearlyMaxRssItems)
    .map { item(forUser: user, episode: $0) }
}

private func item(forUser user: User, episode: Episode) -> RssItem {
  return RssItem(
    description: episode.blurb,
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: .init(
      length: episode.fullVideo.bytesLength,
      type: "video/mp4",
      url: episode.fullVideo.downloadUrl(.hd720)
    ),
    guid: siteRouter.url(for: .episode(.show(.left(episode.slug)))),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: episode.length.rawValue,
      episode: episode.sequence,
      episodeType: .full,
      explicit: false,
      image: episode.image,
      subtitle: episode.blurb,
      summary: episode.blurb,
      season: 1,
      title: episode.fullTitle
    ),
    link: siteRouter.url(for: .episode(.show(.left(episode.slug)))),
    media: .init(
      content: .init(
        length: episode.fullVideo.bytesLength,
        medium: "video",
        type: "video/mp4",
        url: episode.fullVideo.downloadUrl(.hd720)
      ),
      title: episode.fullTitle
    ),
    pubDate: episode.publishedAt,
    title: episode.fullTitle
  )
}

private let invalidatedFeedView = itunesRssFeedLayout { errorMessage in
  node(
    rssChannel: invalidatedChannel(errorMessage: errorMessage),
    items: [invalidatedItem(errorMessage: errorMessage)]
  )
}

private func invalidatedChannel(errorMessage: String) -> RssChannel {
  return .init(
    copyright:
      "Copyright Point-Free, Inc. \(Calendar.current.component(.year, from: Current.date()))",
    description: errorMessage,
    image: .init(
      link: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg",
      title: "Point-Free",
      url: siteRouter.url(for: .home)
    ),
    itunes: .init(
      author: "Brandon Williams & Stephen Celis",
      block: .yes,
      categories: [
        .init(name: "Technology", subcategory: "Software How-To"),
        .init(name: "Education", subcategory: "Training"),
      ],
      explicit: false,
      keywords: [
        "programming",
        "development",
        "mobile",
        "ios",
        "functional",
        "swift",
        "apple",
        "developer",
        "software engineering",
        "server",
        "app",
      ],
      image: .init(
        href: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"),
      owner: .init(email: "support@pointfree.co", name: "Brandon Williams & Stephen Celis"),
      subtitle: "Functional programming concepts explained simply.",
      summary: errorMessage,
      type: .episodic
    ),
    language: "en-US",
    link: siteRouter.url(for: .home),
    title: "Point-Free"
  )
}

private func invalidatedItem(errorMessage: String) -> RssItem {
  let episode = Current.episodes()[0]
  return RssItem(
    description: errorMessage,
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: .init(
      length: episode.fullVideo.bytesLength,
      type: "video/mp4",
      url: episode.fullVideo.downloadUrl(.sd540)
    ),
    guid: String(Current.date().timeIntervalSince1970),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: 0,
      episode: 1,
      episodeType: .full,
      explicit: false,
      image: episode.image,
      subtitle: errorMessage,
      summary: errorMessage,
      season: 1,
      title: "Invalid Feed URL"
    ),
    link: siteRouter.url(for: .home),
    media: .init(
      content: .init(
        length: episode.fullVideo.bytesLength,
        medium: "video",
        type: "video/mp4",
        url: episode.fullVideo.downloadUrl(.sd540)
      ),
      title: "Invalid Feed URL"
    ),
    pubDate: Date.distantFuture,
    title: "Invalid Feed URL"
  )
}

func clearHeadBody<I>(_ conn: Conn<I, Data>) -> IO<Conn<I, Data>> {
  return IO {
    // TODO: this doesn't actually work. The `conn.request.httpBody` has all the
    // data, and that's what needs to be cleared.
    conn.request.httpMethod == "HEAD"
      ? conn.map(const(Data()))
      : conn
  }
}

private func fetchUserSubscription<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Models.Subscription?, User, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{

  return { conn in
    guard let subscriptionId = get1(conn.data).subscriptionId else {
      return conn.map(const(nil .*. conn.data)) |> middleware
    }

    let subscription = EitherIO {
      try await requireSome(Current.database.fetchSubscriptionById(subscriptionId))
    }
    .run
    .map(\.right)

    return subscription.flatMap { conn.map(const($0 .*. conn.data)) |> middleware }
  }
}
