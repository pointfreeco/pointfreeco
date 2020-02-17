import ApplicativeRouter
import Foundation
import Either
import Html
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Syndication
import Tuple

let accountRssMiddleware = decryptUrlAndFetchUser
  <<< validateUserAndSaltAndUserAgent
  <<< fetchActiveStripeSubscription
  <| map(lower)
  >>> accountRssResponse

private let decryptUrlAndFetchUser
  : MT<Tuple2<Encrypted<String>, Encrypted<String>>, Tuple2<User, User.RssSalt>>
  = decryptUrl <<< { fetchUser >=> $0 } <<< requireUser

private let validateUserAndSaltAndUserAgent
  : MT<Tuple2<User, User.RssSalt>, Tuple1<User>>
  = validateUserAndSalt <<< validateUserAgent

private let fetchActiveStripeSubscription
  : MT<Tuple1<User>, Tuple2<Stripe.Subscription?, User>>
  = fetchUserSubscription <<< requireActiveSubscription <<< fetchStripeSubscriptionForUser

private let decryptUrl: (
  @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<User.Id, User.RssSalt>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<Encrypted<String>, Encrypted<String>>, Data> =
  filterMap(
    decryptUserIdAndRssSalt,
    or: invalidatedFeedMiddleware(errorMessage: """
      ‼️ The URL for this feed has been turned off by Point-Free due to suspicious activity. You can \
      retrieve your most up-to-date private podcast URL by visiting your account page at \
      \(url(to: .account(.index))). If you think this is an error, please contact support@pointfree.co.
      """)
)

private func requireUser<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<User, Z>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, T2<User?, Z>, Data> {
  return middleware
    |> filterMap(
      require1 >>> pure,
      or: invalidatedFeedMiddleware(errorMessage: """
        ‼️ The user for this RSS feed could not be found, so we have disabled this feed. You can retrieve \
        your most up-to-date private podcast URL by visiting your account page at \
        \(url(to: .account(.index))). If you think this is an error, please contact support@pointfree.co.
        """)
  )
}

private let requireActiveSubscription: (
  @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple1<User>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<Models.Subscription?, User>, Data> =
  filterMap(
    validateActiveSubscriber,
    or: invalidatedFeedMiddleware(errorMessage: """
      ‼️ The URL for this feed has been turned off by Point-Free as the associated subscription is no longer \
      active. If you would like reactive this feed you can resubscribe to Point-Free on your account page at \
      \(url(to: .account(.index))). If you think this is an error, please contact support@pointfree.co.
      """)
)

private let accountRssResponse
  : Middleware<StatusLineOpen, ResponseEnded, (Stripe.Subscription?, User), Data>
  = writeStatus(.ok)
    >=> trackFeedRequest
    >=> respond(privateEpisodesFeedView, contentType: .text(.init(rawValue: "xml"), charset: .utf8))
    >=> clearHeadBody

private func invalidatedFeedMiddleware<A>(errorMessage: String) -> (Conn<StatusLineOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  return { conn in
    conn.map(const(errorMessage))
      |> writeStatus(.ok)
      >=> respond(invalidatedFeedView, contentType: .text(.init(rawValue: "xml"), charset: .utf8))
      >=> clearHeadBody
  }
}

private func decryptUserIdAndRssSalt<Z>(
  data: T3<Encrypted<String>, Encrypted<String>, Z>
  ) -> IO<T3<User.Id, User.RssSalt, Z>?> {

  return IO {
    let encryptedUserId = get1(data)
    let encryptedRssSalt = get2(data)
    guard
      let userId = encryptedUserId.decrypt(with: Current.envVars.appSecret)
        .flatMap(UUID.init(uuidString:))
        .map(User.Id.init),
      let rssSalt = encryptedRssSalt.decrypt(with: Current.envVars.appSecret)
        .flatMap(UUID.init(uuidString:))
        .map(User.RssSalt.init)
      else { return nil }
    return userId .*. rssSalt .*. rest(data)
  }
}

private func validateActiveSubscriber<Z>(
  data: T3<Models.Subscription?, User, Z>
  ) -> IO<T2<User, Z>?> {

  return IO {
    guard let subscription = get1(data) else { return nil }
    let user = get2(data)

    return SubscriberState(user: user, subscriptionAndEnterpriseAccount: (subscription, nil)).isActive
      ? user .*. rest(data)
      : nil
  }
}

private func validateUserAndSalt<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<User, Z>, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, T3<User, User.RssSalt, Z>, Data> {

    return { conn in
      guard get1(conn.data).rssSalt == get2(conn.data) else {
        return conn
          |> invalidatedFeedMiddleware(errorMessage: """
            ‼️ The URL for this feed has been turned off by Point-Free due to suspicious activity. You can \
            retrieve your most up-to-date private podcast URL by visiting your account page at \
            \(url(to: .account(.index))). If you think this is an error, please contact support@pointfree.co.
            """)
      }
      return conn.map(const(get1(conn.data) .*. rest(conn.data)))
        |> middleware
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

    return Current.database.updateUser(user.id, nil, nil, nil, nil, User.RssSalt(rawValue: Current.uuid()))
      .run
      .flatMap { _ in
        conn
          |> invalidatedFeedMiddleware(errorMessage: """
            ‼️ The URL for this feed has been turned off by Point-Free due to suspicious activity. You can \
            retrieve your most up-to-date private podcast URL by visiting your account page at \
            \(url(to: .account(.index))). If you think this is an error, please contact support@pointfree.co.
            """)
    }
  }
}

private func trackFeedRequest<I>(_ conn: Conn<I, (Stripe.Subscription?, User)>) -> IO<Conn<I, (Stripe.Subscription?, User)>> {

  return Current.database.createFeedRequestEvent(
    .privateEpisodesFeed,
    conn.request.allHTTPHeaderFields?["User-Agent"] ?? "",
    conn.data.1.id
    )
    .withExcept(notifyError(subject: "Create Feed Request Event Failed"))
    .run
    .map { _ in conn }
}

private func fetchStripeSubscriptionForUser<A>(
  _ middleware: (@escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription?, User, A>, Data>)
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data> {

    return { conn in
      conn.data.first.subscriptionId
        .map {
          Current.database.fetchSubscriptionById($0)
            .mapExcept(requireSome)
            .flatMap(Current.stripe.fetchSubscription <<< ^\.stripeSubscriptionId)
            .run
            .map(^\.right)
            .flatMap { conn.map(const($0 .*. conn.data)) |> middleware }
        }
        ?? (conn.map(const(nil .*. conn.data)) |> middleware)
    }
}

private let privateEpisodesFeedView = itunesRssFeedLayout { (data: (subscription: Stripe.Subscription?, user: User)) -> Node in
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
    copyright: "Copyright Point-Free, Inc. \(Calendar.current.component(.year, from: Current.date()))",
    description: description,
    image: .init(
      link: url(to: .home),
      title: title,
      url: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"
    ),
    itunes: .init(
      author: "Brandon Williams & Stephen Celis",
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
        "app"
      ],
      image: .init(href: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"),
      owner: .init(email: "support@pointfree.co", name: "Brandon Williams & Stephen Celis"),
      subtitle: "Functional programming concepts explained simply.",
      summary: description,
      type: .episodic
    ),
    language: "en-US",
    link: url(to: .home),
    title: title
  )
}

let nonYearlyMaxRssItems = 4

private func items(forUser user: User, subscription: Stripe.Subscription?) -> [RssItem] {
  return Current
    .episodes()
    .filter { $0.sequence != 0 }
    .sorted(by: their(^\.sequence, >))
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
      url: episode.fullVideo.downloadUrl
    ),
    guid: url(to: .episode(.left(episode.slug))),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: episode.length,
      episode: episode.sequence,
      episodeType: .full,
      explicit: false,
      image: episode.itunesImage ?? "",
      subtitle: episode.blurb,
      summary: episode.blurb,
      season: 1,
      title: episode.title
    ),
    link: url(to: .episode(.left(episode.slug))),
    media: .init(
      content: .init(
        length: episode.fullVideo.bytesLength,
        medium: "video",
        type: "video/mp4",
        url: episode.fullVideo.downloadUrl
      ),
      title: episode.title
    ),
    pubDate: episode.publishedAt,
    title: episode.title
  )
}

private let invalidatedFeedView = itunesRssFeedLayout { errorMessage in
  node(
    rssChannel: invalidatedChannel(errorMessage: errorMessage),
    items: [invalidatedItem(errorMessage: errorMessage)]
  )
}

private func invalidatedChannel(errorMessage: String) -> RssChannel {
  return .init (
    copyright: "Copyright Point-Free, Inc. \(Calendar.current.component(.year, from: Current.date()))",
    description: errorMessage,
    image: .init(
      link: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg",
      title: "Point-Free",
      url: url(to: .home)
    ),
    itunes: .init(
      author: "Brandon Williams & Stephen Celis",
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
        "app"
      ],
      image: .init(href: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"),
      owner: .init(email: "support@pointfree.co", name: "Brandon Williams & Stephen Celis"),
      subtitle: "Functional programming concepts explained simply.",
      summary: errorMessage,
      type: .episodic
    ),
    language: "en-US",
    link: url(to: .home),
    title: "Point-Free"
  )
}

private func invalidatedItem(errorMessage: String) -> RssItem {
  return RssItem(
    description: errorMessage,
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: .init(
      length: introduction.fullVideo.bytesLength,
      type: "video/mp4",
      url: introduction.fullVideo.downloadUrl
    ),
    guid: String(Current.date().timeIntervalSince1970),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: 0,
      episode: 1,
      episodeType: .full,
      explicit: false,
      image: introduction.itunesImage ?? "",
      subtitle: errorMessage,
      summary: errorMessage,
      season: 1,
      title: "Invalid Feed URL"
    ),
    link: url(to: .home),
    media: .init(
      content: .init(
        length: introduction.fullVideo.bytesLength,
        medium: "video",
        type: "video/mp4",
        url: introduction.fullVideo.downloadUrl
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
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Models.Subscription?, User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data> {

    return { conn in
      guard let subscriptionId = get1(conn.data).subscriptionId else {
        return conn.map(const(nil .*. conn.data)) |> middleware
      }

      let subscription = Current.database.fetchSubscriptionById(subscriptionId)
        .mapExcept(requireSome)
        .run
        .map(^\.right)

      return subscription.flatMap { conn.map(const($0 .*. conn.data)) |> middleware }
    }
}
