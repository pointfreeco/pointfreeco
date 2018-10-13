import Foundation
import Html
import Optics
import Prelude
import View

struct RssChannel {
  var copyright: String
  var description: String
  var image: Image
  var itunes: Itunes?
  var language: String
  var link: String
  var title: String

  struct Image {
    var link: String
    var title: String
    var url: String
  }

  struct Itunes {
    var author: String
    var categories: [Category]
    var explicit: Bool
    var keywords: [String]
    var image: Image
    var owner: Owner
    var subtitle: String
    var summary: String
    var type: ChannelType

    enum ChannelType: String {
      case episodic
      case serial
    }

    struct Image {
      var href: String
    }

    struct Category {
      var name: String
      var subcategory: String
    }

    struct Owner {
      var email: String
      var name: String
    }
  }
}

struct RssItem {
  var description: String
  var dublinCore: DublinCore?
  var enclosure: Enclosure?
  var guid: String
  var itunes: Itunes?
  var link: String
  var media: Media?
  var pubDate: Date
  var title: String

  struct DublinCore {
    var creators: [String]
  }

  struct Enclosure {
    var length: Int
    var type: String
    var url: String
  }

  struct Itunes {
    var author: String
    var duration: Int
    var episode: Int
    var episodeType: EpisodeType
    var explicit: Bool
    var image: String
    var subtitle: String
    var summary: String
    var season: Int
    var title: String

    enum EpisodeType: String {
      case bonus
      case full
      case trailer
    }
  }

  struct Media {
    var content: Content
    var title: String

    struct Content {
      var length: Int
      var medium: String
      var type: String
      var url: String
    }
  }
}

func node(rssChannel channel: RssChannel, items: [RssItem]) -> Node {
  let itunesNodes = channel.itunes.map(nodes(itunes:)) ?? []

  return element(
    "channel",
    [
      element("title", [text(channel.title)]),
      element("link", [text(channel.link)]),
      element("language", [text(channel.language)]),
      element("description", [text(channel.description)]),
      element("copyright", [text(channel.copyright)]),

      element(
        "image",
        [
          element("url", [text(channel.image.url)]),
          element("title", [text(channel.image.title)]),
          element("link", [text(channel.image.link)]),
          ]
      )
      ]
      + itunesNodes
      + items.map(node(rssItem:))
  )
}

func itunesRssFeedLayout<A>(_ view: View<A>) -> View<A> {
  return View { a in
    [
      .raw(
        """
        <?xml version="1.0" encoding="utf-8" ?>
        """
      ),
      element(
        "rss",
        [
          .init("xmlns:itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd") as Attribute<Void>,
          .init("xmlns:rawvoice", "http://www.rawvoice.com/rawvoiceRssModule/"),
          .init("xmlns:dc", "http://purl.org/dc/elements/1.1/"),
          .init("xmlns:media", "http://www.rssboard.org/media-rss"),
          .init("xmlns:atom", "http://www.w3.org/2005/Atom"),
          .init("version", "2.0")
        ],
        view.view(a)
      )
    ]
  }
}

private func node(category: RssChannel.Itunes.Category) -> Node {
  return element(
    "itunes:category",
    [.init("text", category.name) as Attribute<Void>],
    [element("itunes:category", [text(category.subcategory)])]
  )
}

private func nodes(itunes: RssChannel.Itunes) -> [Node] {

  return [
    element("itunes:author", [text(itunes.author)]),
    element("itunes:subtitle", [text(itunes.subtitle)]),
    element("itunes:summary", [text(itunes.summary)]),
    element("itunes:explicit", [text(yesOrNo(itunes.explicit))]),
    element(
      "itunes:owner",
      [
        element("itunes:name", [text(itunes.owner.name)]),
        element("itunes:email", [text(itunes.owner.email)])
      ]
    ),
    element("itunes:type", [text(itunes.type.rawValue)]),
    element("itunes:keywords", [text(itunes.keywords.joined(separator: ","))]),
    element(
      "itunes:image",
      [.init("href", itunes.image.href) as Attribute<Void>],
      []
    )
    ]
    + itunes.categories.map(node(category:))
}

private func nodes(itunes: RssItem.Itunes) -> [Node] {
  return [
    element("itunes:author", [text(itunes.author)]),
    element("itunes:subtitle", [text(itunes.subtitle)]),
    element("itunes:summary", [text(itunes.summary)]),
    element("itunes:explicit", ["no"]),
    element("itunes:duration", [text(timestampLabel(for: itunes.duration))]),
    element("itunes:image", [text(itunes.image)]),
    element("itunes:season", [text("\(itunes.season)")]),
    element("itunes:episode", [text("\(itunes.episode)")]),
    element("itunes:title", [text(itunes.title)]),
    element("itunes:episodeType", [text(itunes.episodeType.rawValue)])
  ]
}

private func node(rssItem: RssItem) -> Node {
  let creatorNodes = (rssItem.dublinCore?.creators ?? []).map {
    element("dc:creator", [text($0)])
  }
  let itunesNodes = rssItem.itunes.map(nodes(itunes:)) ?? []
  let enclosureNodes = [
    rssItem.enclosure.map { enclosure in
      element(
        "enclosure",
        [
          .init("url", enclosure.url) as Attribute<Void>,
          .init("length", "\(enclosure.length)"),
          .init("type", enclosure.type),
          ],
        []
      )
    }
    ]
    .compactMap(id)

  let mediaNodes = [
    rssItem.media.map { media in
      element(
        "media:content",
        [
          .init("url", media.content.url) as Attribute<Void>,
          .init("length", "\(media.content.length)"),
          .init("type", media.content.type),
          .init("medium", media.content.medium)
        ],
        [
          element("media:title", [text(media.title)])
        ]
      )
    }
    ]
    .compactMap(id)

  return element(
    "item",
    [
      element("title", [text(rssItem.title)]),
      element("pubDate", [text(rssDateFormatter.string(from: rssItem.pubDate))]),
      element("link", [text(rssItem.link)]),
      element("guid", [text(rssItem.guid)]),
      element("description", [text(rssItem.description)])
      ]
      + creatorNodes
      + itunesNodes
      + enclosureNodes
      + mediaNodes
  )
}

private func yesOrNo(_ bool: Bool) -> String {
  return bool ? "yes" : "no"
}

private let rssDateFormatter = DateFormatter()
  |> \.dateFormat .~ "EEE, dd MMM yyyy HH:mm:ss Z"
  |> \.locale .~ Locale(identifier: "en_US_POSIX")
  |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

private func timestampLabel(for timestamp: Int) -> String {
  let hour = Int(timestamp / 60 / 60)
  let minute = Int(timestamp / 60) % 60
  let second = Int(timestamp) % 60
  let hourString = hour >= 10 ? "\(hour)" : "0\(hour)"
  let minuteString = minute >= 10 ? "\(minute)" : "0\(minute)"
  let secondString = second >= 10 ? "\(second)" : "0\(second)"
  return "\(hourString):\(minuteString):\(secondString)"
}
