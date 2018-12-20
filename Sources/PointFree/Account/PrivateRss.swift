import Foundation
import Either
import Html
import HttpPipeline
import Optics
import Prelude
import Tuple
import View

let accountRssMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, Database.User.RssSalt>, Data> =
{ fetchUser >=> $0 }
  <<< filterMap(require1 >>> pure, or: invalidatedFeedMiddleware(errorMessage: "Couldn't find user"))
  <<< validateUserAndSalt
  <<< fetchUserSubscription
  <<< filterMap(validateActiveSubscriber, or: invalidatedFeedMiddleware(errorMessage: "Couldn't validate active subscription"))
  <<< fetchStripeSubscriptionForUser
  <| map(lower)
  >>> writeStatus(.ok)
  >=> trackFeedRequest
  >=> respond(privateEpisodesFeedView, contentType: .text(.init(rawValue: "xml"), charset: .utf8))
  >=> clearHeadBody

private func invalidatedFeedMiddleware<A>(errorMessage: String) -> (Conn<StatusLineOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  return { conn in
    conn.map(const(unit))
      |> writeStatus(.ok)
      >=> respond(invalidatedFeedView, contentType: .text(.init(rawValue: "xml"), charset: .utf8))
      >=> clearHeadBody
  }
}

private func validateActiveSubscriber<Z>(
  data: T3<Database.Subscription?, Database.User, Z>
  ) -> IO<T2<Database.User, Z>?> {

  return IO {
    guard let subscription = get1(data) else { return nil }
    let user = get2(data)

    return SubscriberState(user: user, subscription: subscription).isActive
      ? user .*. rest(data)
      : nil
  }
}

private func validateUserAndSalt<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, Z>, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Database.User, Database.User.RssSalt, Z>, Data> {

    return { conn in
      guard get1(conn.data).rssSalt == get2(conn.data) else {
        return conn
          |> invalidatedFeedMiddleware(errorMessage: "Couldn't validate rss salt")
      }
      return conn.map(const(get1(conn.data) .*. rest(conn.data)))
        |> middleware
    }
}

private func trackFeedRequest<I>(_ conn: Conn<I, (Stripe.Subscription?, Database.User)>) -> IO<Conn<I, (Stripe.Subscription?, Database.User)>> {

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
  _ middleware: (@escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription?, Database.User, A>, Data>)
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

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

private let privateEpisodesFeedView = itunesRssFeedLayout <| View<(Stripe.Subscription?, Database.User)> { subscription, user -> Node in
  node(
    rssChannel: privateRssChannel(user: user),
    items: items(forUser: user, subscription: subscription)
  )
}

func privateRssChannel(user: Database.User) -> RssChannel {
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

private func items(forUser user: Database.User, subscription: Stripe.Subscription?) -> [RssItem] {
  return Current
    .episodes()
    .filter { $0.sequence != 0 }
    .sorted(by: their(^\.sequence, >))
    .prefix(subscription?.plan.interval == .some(.year) ? 99999 : nonYearlyMaxRssItems)
    .map { item(forUser: user, episode: $0) }
}

private func item(forUser user: Database.User, episode: Episode) -> RssItem {
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

private let invalidatedFeedView = itunesRssFeedLayout <| View<Prelude.Unit> { _ in
  node(
    rssChannel: invalidatedChannel,
    items: [invalidatedItem]
  )
}

private var invalidatedChannel: RssChannel {
  return .init (
    copyright: "Copyright Point-Free, Inc. \(Calendar.current.component(.year, from: Current.date()))",
    description: invalidatedDescription,
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
      summary: invalidatedDescription,
      type: .episodic
    ),
    language: "en-US",
    link: url(to: .home),
    title: "Point-Free"
  )
}

private var invalidatedItem: RssItem {
  return RssItem(
    description: invalidatedDescription,
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
      subtitle: invalidatedDescription,
      summary: invalidatedDescription,
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
    pubDate: introduction.publishedAt,
    title: "Invalid Feed URL"
  )
}

private var invalidatedDescription: String {
  return """
‼️ The URL for this feed has been turned off by Point-Free. You can retrieve your most up-to-date private \
podcast URL by visiting your account page at \(url(to: .account(.index))). If you think this is an error, \
please contact support@pointfree.co.
"""
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
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription?, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

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
