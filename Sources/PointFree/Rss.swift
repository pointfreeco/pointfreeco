import Foundation
import Html
import Optics
import Prelude

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

func node(category: RssChannel.Itunes.Category) -> Node {
  return node(
    "itunes:category",
    [attribute("text", category.name) as Attribute<Void>],
    [node("itunes:category", [text(category.subcategory)])]
  )
}

func nodes(itunes: RssChannel.Itunes) -> [Node] {

  return [
    node("itunes:author", [text(itunes.author)]),
    node("itunes:subtitle", [text(itunes.subtitle)]),
    node("itunes:summary", [text(itunes.summary)]),
    node("itunes:explicit", [text(yesOrNo(itunes.explicit))]),
    node(
      "itunes:owner",
      [
        node("itunes:name", [text(itunes.owner.name)]),
        node("itunes:email", [text(itunes.owner.email)])
      ]
    ),
    node("itunes:type", [text(itunes.type.rawValue)]),
    node("itunes:keywords", [text(itunes.keywords.joined(separator: ","))]),
    node(
      "itunes:image",
      [attribute("href", itunes.image.href) as Attribute<Void>],
      []
    )
    ]
    + itunes.categories.map(node(category:))
}

func nodes(itunes: RssItem.Itunes) -> [Node] {
  return [
    node("itunes:author", [text(itunes.author)]),
    node("itunes:subtitle", [text(itunes.subtitle)]),
    node("itunes:summary", [text(itunes.summary)]),
    node("itunes:explicit", ["no"]),
    node("itunes:duration", [text(timestampLabel(for: itunes.duration))]),
    node("itunes:image", [text(itunes.image)]),
    node("itunes:season", [text("\(itunes.season)")]),
    node("itunes:episode", [text("\(itunes.episode)")]),
    node("itunes:title", [text(itunes.title)]),
    node("itunes:episodeType", [text(itunes.episodeType.rawValue)])
  ]
}

func node(rssItem: RssItem) -> Node {
  let creatorNodes = (rssItem.dublinCore?.creators ?? []).map {
    node("dc:creator", [text($0)])
  }
  let itunesNodes = rssItem.itunes.map(nodes(itunes:)) ?? []
  let enclosureNodes = [
    rssItem.enclosure.map { enclosure in
      node(
        "enclosure",
        [
          attribute("url", enclosure.url) as Attribute<Void>,
          attribute("length", "\(enclosure.length)"),
          attribute("type", enclosure.type),
          ],
        []
      )
    }
    ]
    .compactMap(id)

  let mediaNodes = [
    rssItem.media.map { media in
      node(
        "media:content",
        [
          attribute("url", media.content.url) as Attribute<Void>,
          attribute("length", "\(media.content.length)"),
          attribute("type", media.content.type),
          attribute("medium", media.content.medium)
        ],
        [
          node("media:title", [text(media.title)])
        ]
      )
    }
    ]
    .compactMap(id)

  return node(
    "item",
    [
      node("title", [text(rssItem.title)]),
      node("pubDate", [text(rssDateFormatter.string(from: rssItem.pubDate))]),
      node("link", [text(rssItem.link)]),
      node("guid", [text(rssItem.guid)]),
      node("description", [text(rssItem.description)])
      ]
      + creatorNodes
      + itunesNodes
      + enclosureNodes
      + mediaNodes
  )
}

func node(rssChannel channel: RssChannel, items: [RssItem]) -> Node {
  let itunesNodes = channel.itunes.map(nodes(itunes:)) ?? []

  return node(
    "channel",
    [
      node("title", [text(channel.title)]),
      node("link", [text(channel.link)]),
      node("language", [text(channel.language)]),
      node("description", [text(channel.description)]),
      node("copyright", [text(channel.copyright)]),

      node(
        "image",
        [
          node("url", [text(channel.image.url)]),
          node("title", [text(channel.image.title)]),
          node("link", [text(channel.image.link)]),
          ]
      )
      ]
      + itunesNodes
      + items.map(node(rssItem:))
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
  let minute = Int(timestamp / 60)
  let second = Int(timestamp) % 60
  let hourString = hour >= 10 ? "\(hour)" : "0\(hour)"
  let minuteString = minute >= 10 ? "\(minute)" : "0\(minute)"
  let secondString = second >= 10 ? "\(second)" : "0\(second)"
  return "\(hourString):\(minuteString):\(secondString)"
}
