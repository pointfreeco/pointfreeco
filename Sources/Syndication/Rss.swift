import Foundation
import HtmlUpgrade

public struct RssChannel {
  public var copyright: String
  public var description: String
  public var image: Image
  public var itunes: Itunes?
  public var language: String
  public var link: String
  public var title: String

  public init(
    copyright: String,
    description: String,
    image: Image,
    itunes: Itunes?,
    language: String,
    link: String,
    title: String) {
    self.copyright = copyright
    self.description = description
    self.image = image
    self.itunes = itunes
    self.language = language
    self.link = link
    self.title = title
  }

  public struct Image {
    public var link: String
    public var title: String
    public var url: String

    public init(
      link: String,
      title: String,
      url: String) {
      self.link = link
      self.title = title
      self.url = url
    }
  }

  public struct Itunes {
    public var author: String
    public var categories: [Category]
    public var explicit: Bool
    public var keywords: [String]
    public var image: Image
    public var owner: Owner
    public var subtitle: String
    public var summary: String
    public var type: ChannelType

    public init(
      author: String,
      categories: [Category],
      explicit: Bool,
      keywords: [String],
      image: Image,
      owner: Owner,
      subtitle: String,
      summary: String,
      type: ChannelType) {
      self.author = author
      self.categories = categories
      self.explicit = explicit
      self.keywords = keywords
      self.image = image
      self.owner = owner
      self.subtitle = subtitle
      self.summary = summary
      self.type = type
    }

    public enum ChannelType: String {
      case episodic
      case serial
    }

    public struct Image {
      public var href: String

      public init(href: String) {
        self.href = href
      }
    }

    public struct Category {
      public var name: String
      public var subcategory: String

      public init(
        name: String,
        subcategory: String) {
        self.name = name
        self.subcategory = subcategory
      }
    }

    public struct Owner {
      public var email: String
      public var name: String

      public init(
        email: String,
        name: String) {
        self.email = email
        self.name = name
      }
    }
  }
}

public struct RssItem {
  public var description: String
  public var dublinCore: DublinCore?
  public var enclosure: Enclosure?
  public var guid: String
  public var itunes: Itunes?
  public var link: String
  public var media: Media?
  public var pubDate: Date
  public var title: String

  public init(
    description: String,
    dublinCore: DublinCore?,
    enclosure: Enclosure?,
    guid: String,
    itunes: Itunes?,
    link: String,
    media: Media?,
    pubDate: Date,
    title: String) {
    self.description = description
    self.dublinCore = dublinCore
    self.enclosure = enclosure
    self.guid = guid
    self.itunes = itunes
    self.link = link
    self.media = media
    self.pubDate = pubDate
    self.title = title
  }

  public struct DublinCore {
    public var creators: [String]

    public init(creators: [String]) {
      self.creators = creators
    }
  }

  public struct Enclosure {
    public var length: Int
    public var type: String
    public var url: String

    public init(
      length: Int,
      type: String,
      url: String) {
      self.length = length
      self.type = type
      self.url = url
    }
  }

  public struct Itunes {
    public var author: String
    public var duration: Int
    public var episode: Int
    public var episodeType: EpisodeType
    public var explicit: Bool
    public var image: String
    public var subtitle: String
    public var summary: String
    public var season: Int
    public var title: String

    public init(
      author: String,
      duration: Int,
      episode: Int,
      episodeType: EpisodeType,
      explicit: Bool,
      image: String,
      subtitle: String,
      summary: String,
      season: Int,
      title: String) {
      self.author = author
      self.duration = duration
      self.episode = episode
      self.episodeType = episodeType
      self.explicit = explicit
      self.image = image
      self.subtitle = subtitle
      self.summary = summary
      self.season = season
      self.title = title
    }

    public enum EpisodeType: String {
      case bonus
      case full
      case trailer
    }
  }

  public struct Media {
    public var content: Content
    public var title: String

    public init(
      content: Content,
      title: String) {
      self.content = content
      self.title = title
    }

    public struct Content {
      public var length: Int
      public var medium: String
      public var type: String
      public var url: String

      public init(
        length: Int,
        medium: String,
        type: String,
        url: String) {
        self.length = length
        self.medium = medium
        self.type = type
        self.url = url
      }
    }
  }
}

public func node(rssChannel channel: RssChannel, items: [RssItem]) -> Node {
  let itunesNodes = channel.itunes.map(nodes(itunes:)) ?? .fragment([])

  return .element(
    "channel",
    [],
    .fragment([
      .element("title", [], .text(channel.title)),
      .element("link", [], .text(channel.link)),
      .element("language", [], .text(channel.language)),
      .element("description", [], .text(channel.description)),
      .element("copyright", [], .text(channel.copyright)),
      .element(
        "image",
        [],
        .fragment([
          .element("url", [], .text(channel.image.url)),
          .element("title", [], .text(channel.image.title)),
          .element("link", [], .text(channel.image.link))
        ])
      ),
      itunesNodes,
      .fragment(items.map(node(rssItem:)))
    ])
  )
}

public func itunesRssFeedLayout<A>(_ view: @escaping (A) -> Node) -> (A) -> Node {
  return { a in
    [
      .raw(
        """
        <?xml version="1.0" encoding="utf-8" ?>
        """
      ),
      .element(
        "rss",
        [
          ("xmlns:itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd"),
          ("xmlns:rawvoice", "http://www.rawvoice.com/rawvoiceRssModule/"),
          ("xmlns:dc", "http://purl.org/dc/elements/1.1/"),
          ("xmlns:media", "http://www.rssboard.org/media-rss"),
          ("xmlns:atom", "http://www.w3.org/2005/Atom"),
          ("version", "2.0")
        ],
        view(a)
      )
    ]
  }
}

private func node(category: RssChannel.Itunes.Category) -> Node {
  return .element(
    "itunes:category",
    [("text", category.name)],
    .element("itunes:category", [], .text(category.subcategory))
  )
}

private func nodes(itunes: RssChannel.Itunes) -> Node {
  return [
    .element("itunes:author", [], .text(itunes.author)),
    .element("itunes:subtitle", [], .text(itunes.subtitle)),
    .element("itunes:summary", [], .text(itunes.summary)),
    .element("itunes:explicit", [], .text(yesOrNo(itunes.explicit))),
    .element(
      "itunes:owner",
      [],
      .fragment([
        .element("itunes:name", [], .text(itunes.owner.name)),
        .element("itunes:email", [], .text(itunes.owner.email))
      ])
    ),
    .element("itunes:type", [], .text(itunes.type.rawValue)),
    .element("itunes:keywords", [], .text(itunes.keywords.joined(separator: ","))),
    .element(
      "itunes:image",
      [("href", itunes.image.href)],
      ""
    ),
    .fragment(itunes.categories.map(node(category:)))
  ]
}

private func nodes(itunes: RssItem.Itunes) -> Node {
  return [
    .element("itunes:author", [], .text(itunes.author)),
    .element("itunes:subtitle", [], .text(itunes.subtitle)),
    .element("itunes:summary", [], .text(itunes.summary)),
    .element("itunes:explicit", [], "no"),
    .element("itunes:duration", [], .text(timestampLabel(for: itunes.duration))),
    .element("itunes:image", [], .text(itunes.image)),
    .element("itunes:season", [], .text("\(itunes.season)")),
    .element("itunes:episode", [], .text("\(itunes.episode)")),
    .element("itunes:title", [], .text(itunes.title)),
    .element("itunes:episodeType", [], .text(itunes.episodeType.rawValue))
  ]
}

private func node(rssItem: RssItem) -> Node {
  let creatorNodes = Node.fragment(
    (rssItem.dublinCore?.creators ?? []).map { .element("dc:creator", [], .text($0)) }
  )
  let itunesNodes = rssItem.itunes.map(nodes(itunes:)) ?? .fragment([])
  let enclosureNodes = rssItem.enclosure.map { enclosure in
    .element(
      "enclosure",
      [
        ("url", enclosure.url.replacingOccurrences(of: "&", with: "&amp;")),
        ("length", "\(enclosure.length)"),
        ("type", enclosure.type),
      ],
      []
    )
    }
    ?? Node.fragment([])

  let mediaNodes = rssItem.media.map { media in
    .element(
      "media:content",
      [
        ("url", media.content.url.replacingOccurrences(of: "&", with: "&amp;")),
        ("length", "\(media.content.length)"),
        ("type", media.content.type),
        ("medium", media.content.medium)
      ],
      .element("media:title", [], .text(media.title))
    )
    }
    ?? Node.fragment([])

  return .element(
    "item",
    [],
    .fragment([
      .element("title", [], .text(rssItem.title)),
      .element("pubDate", [], .text(rssDateFormatter.string(from: rssItem.pubDate))),
      .element("link", [], .text(rssItem.link)),
      .element("guid", [], .text(rssItem.guid)),
      .element("description", [], .text(rssItem.description)),
      creatorNodes,
      itunesNodes,
      enclosureNodes,
      mediaNodes
    ])
  )
}

private func yesOrNo(_ bool: Bool) -> String {
  return bool ? "yes" : "no"
}

private let rssDateFormatter = { () -> DateFormatter in
  let df = DateFormatter()
  df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
  df.locale = Locale(identifier: "en_US_POSIX")
  df.timeZone = TimeZone(secondsFromGMT: 0)
  return df
}()

private func timestampLabel(for timestamp: Int) -> String {
  let hour = Int(timestamp / 60 / 60)
  let minute = Int(timestamp / 60) % 60
  let second = Int(timestamp) % 60
  let hourString = hour >= 10 ? "\(hour)" : "0\(hour)"
  let minuteString = minute >= 10 ? "\(minute)" : "0\(minute)"
  let secondString = second >= 10 ? "\(second)" : "0\(second)"
  return "\(hourString):\(minuteString):\(secondString)"
}
