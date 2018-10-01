import Foundation
import Html
import HttpPipeline
import Optics
import Prelude
import Tuple

let accountRssMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, Database.User.RssSalt>, Data> =
{ fetchUser >=> $0 }
  <<< filterMap(
    require1 >>> pure,
    // todo: redirect to atom feed with error summary
    or: redirect(to: .home)
  )
  <<< validateUserAndSalt
  <<< fetchSubscription
  <<< filterMap(
    validateActiveSubscriber,
    // todo: redirect to atom feed with error summary
    or: redirect(to: .home)
  )
  <| privateRssFeedMiddleware

private let privateRssFeedMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple1<Database.User>, Data> =
  map(lower)
    >>> writeStatus(.ok)
    >=> trackFeedRequest
    >=> respond(privateEpisodesFeedView, contentType: .text(.init("xml"), charset: .utf8))
    >=> clearHeadBody

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
        // todo: redirect to atom feed with error summary
        return conn
          |> redirect(to: .home)
      }
      return conn.map(const(get1(conn.data) .*. rest(conn.data)))
        |> middleware
    }
}

private func trackFeedRequest<I>(_ conn: Conn<I, Database.User>) -> IO<Conn<I, Database.User>> {

  return Current.database.createFeedRequestEvent(
    conn.request.allHTTPHeaderFields?["Referer"] ?? "",
    .privateEpisodesFeed,
    conn.request.allHTTPHeaderFields?["User-Agent"] ?? "",
    conn.data.id
    )
    .withExcept(notifyError(subject: "Create Feed Request Event Failed"))
    .run
    .map { _ in conn }
}

private let privateEpisodesFeedView = itunesRssFeedLayout <| View<Database.User> { user -> Node in
  node(
    rssChannel: privateRssChannel(user: user),
    items: items(forUser: user)
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
      link: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg",
      title: title,
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
        "programming,development,mobile,ios,functional,swift,apple,developer,software engineering,server,app"
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

private func items(forUser user: Database.User) -> [RssItem] {
  return [
    Current
      .episodes()
      .filter { $0.sequence != 0 }
      .sorted(by: their(^\.sequence, >))[1]
    ]
    .compactMap(id)
    .map { item(forUser: user, episode: $0) }
}

private func item(forUser user: Database.User, episode: Episode) -> RssItem {
  return RssItem(
    description: episode.blurb,
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: .init(
      length: episode.fullVideo?.bytesLength ?? 0,
      type: "video/mp4",
      url: episode.fullVideo?.downloadUrl ?? ""
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
        length: episode.fullVideo?.bytesLength ?? 0,
        medium: "video",
        type: "video/mp4",
        url: episode.fullVideo?.downloadUrl ?? ""
      ),
      title: episode.title
    ),
    pubDate: episode.publishedAt,
    title: episode.title
  )
}

func clearHeadBody<I>(_ conn: Conn<I, Data>) -> IO<Conn<I, Data>> {
  return IO {
    conn.request.httpMethod == "HEAD"
      ? conn.map(const(Data()))
      : conn
  }
}
