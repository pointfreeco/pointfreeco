import Dependencies
import Foundation
import Html
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Syndication

func episodesRssMiddleware(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respond(xml: episodesFeedView)
    .clearBodyForHeadRequests()
}

func slackEpisodesRssMiddleware(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  return conn
    .writeStatus(.ok)
    .respond(xml: slackEpisodesFeedView)
    .clearBodyForHeadRequests()
}

private let episodesFeedView = itunesRssFeedLayout {
  [
    node(
      rssChannel: freeEpisodeRssChannel,
      items: items()
    )
  ]
}

private let slackEpisodesFeedView = itunesRssFeedLayout {
  [
    node(
      rssChannel: freeEpisodeRssChannel,
      items: slackEpisodes()
    )
  ]
}

var freeEpisodeRssChannel: RssChannel {
  @Dependency(\.calendar) var calendar
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  let description = """
    Point-Free is a video series about functional programming and the Swift programming language. Each episode \
    covers a topic that may seem complex and academic at first, but turns out to be quite simple. At the end of \
    each episode we’ll ask “what’s the point?!”, so that we can bring the concepts back down to earth and show \
    how these ideas can improve the quality of your code today.
    """
  let title = "Point-Free Videos"

  return RssChannel(
    copyright:
      "Copyright Point-Free, Inc. \(calendar.component(.year, from: now))",
    description: description,
    image: .init(
      link: siteRouter.url(for: .home),
      title: title,
      url: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"
    ),
    itunes: .init(
      author: "Brandon Williams & Stephen Celis",
      block: .no,
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

private func items() -> [RssItem] {
  @Dependency(\.episodes) var episodes

  return
  episodes()
    .sorted(by: their({ $0.freeSince ?? $0.publishedAt }, >))
    .prefix(4)
    .map { item(episode: $0) }
}

private func slackEpisodes() -> [RssItem] {
  @Dependency(\.episodes) var episodes

  return episodes()
    .sorted(by: { $0.sequence > $1.sequence })
    .map(slackItem(episode:))
}

private func item(episode: Episode) -> RssItem {
  @Dependency(\.siteRouter) var siteRouter

  func title(episode: Episode) -> String {
    return episode.subscriberOnly
      ? episode.fullTitle
      : "🆓 \(episode.fullTitle)"
  }

  func summary(episode: Episode) -> String {
    return episode.subscriberOnly
      ? "🔒 \(episode.blurb)"
      : "🆓 \(episode.blurb)"
  }

  func description(episode: Episode) -> String {
    @Dependency(\.date.now) var now

    switch episode.permission {
    case .free:
      return """
        Every once in awhile we release a new episode free for all to see, and today is that day! Please enjoy \
        this episode, and if you find this interesting you may want to consider a subscription \
        \(siteRouter.url(for: .pricingLanding)).

        ---

        \(episode.blurb)
        """
    case let .freeDuring(range) where range.contains(now):
      return """
        Free Episode: Every once in awhile we release a past episode for free to all of our viewers, and today is \
        that day! Please enjoy this episode, and if you find this interesting you may want to consider a \
        subscription \(siteRouter.url(for: .pricingLanding)).

        ---

        \(episode.blurb)
        """
    case .freeDuring, .subscriberOnly:
      return """
        Subscriber-Only: Today's episode is available only to subscribers. If you are a Point-Free subscriber you \
        can access your private podcast feed by visiting \(siteRouter.url(for: .account())).

        ---

        \(episode.blurb)
        """
    }
  }

  func enclosure(episode: Episode) -> RssItem.Enclosure {
    let video = episode.subscriberOnly ? episode.trailerVideo : episode.fullVideo
    return .init(
      length: video.bytesLength,
      type: "video/mp4",
      url: video.downloadUrl(.sd540)
    )
  }

  func mediaContent(episode: Episode) -> RssItem.Media.Content {
    let video = episode.subscriberOnly ? episode.trailerVideo : episode.fullVideo
    return .init(
      length: video.bytesLength,
      medium: "video",
      type: "video/mp4",
      url: video.downloadUrl(.sd540)
    )
  }

  return RssItem(
    description: description(episode: episode),
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: enclosure(episode: episode),
    guid: String(Int((episode.freeSince ?? episode.publishedAt).timeIntervalSince1970)),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: episode.length.rawValue,
      episode: episode.sequence,
      episodeType: episode.subscriberOnly ? .trailer : .full,
      explicit: false,
      image: episode.image,
      subtitle: summary(episode: episode),
      summary: summary(episode: episode),
      season: 1,
      title: title(episode: episode)
    ),
    link: siteRouter.url(for: .episode(.show(.left(episode.slug)))),
    media: .init(
      content: mediaContent(episode: episode),
      title: title(episode: episode)
    ),
    pubDate: episode.freeSince ?? episode.publishedAt,
    title: title(episode: episode)
  )
}

private func slackItem(episode: Episode) -> RssItem {
  @Dependency(\.siteRouter) var siteRouter
  return RssItem(
    description: episode.blurb,
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: nil,
    guid: String(Int((episode.freeSince ?? episode.publishedAt).timeIntervalSince1970)),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: episode.length.rawValue,
      episode: episode.sequence,
      episodeType: episode.subscriberOnly ? .trailer : .full,
      explicit: false,
      image: episode.image,
      subtitle: episode.blurb,
      summary: episode.blurb,
      season: 1,
      title: episode.title
    ),
    link: siteRouter.url(for: .episode(.show(.left(episode.slug)))),
    media: nil,
    pubDate: episode.freeSince ?? episode.publishedAt,
    title: episode.title
  )
}

// TODO: swift-web
extension Html.Application {
  public static var atom = Html.Application(rawValue: "atom+xml")
}

extension Conn where Step == HeadersOpen {
  public func respond(xml view: (A) -> Node) -> Conn<ResponseEnded, Data> {
    @Dependency(\.renderXml) var renderXml

    return
      self
      .respond(
        body: renderXml(view(self.data)),
        contentType: .text(.init(rawValue: "xml"), charset: .utf8)
      )
  }
}

public func respond<A>(_ view: @escaping (A) -> Node, contentType: MediaType = .html) -> Middleware<
  HeadersOpen, ResponseEnded, A, Data
> {
  @Dependency(\.renderXml) var renderXml

  return { conn in
    return conn
      |> respond(
        body: renderXml(view(conn.data)),
        contentType: contentType
      )
  }
}

public func respond<A>(_ node: Node, contentType: MediaType = .html) -> Middleware<
  HeadersOpen, ResponseEnded, A, Data
> {
  @Dependency(\.renderXml) var renderXml

  return { conn in
    conn
      |> respond(
        body: renderXml(node),
        contentType: contentType
      )
  }
}
