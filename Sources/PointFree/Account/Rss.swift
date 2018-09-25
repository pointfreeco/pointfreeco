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
  <| trackFeedRequest
  >=> writeStatus(.ok)
  >=> respond(feedView, contentType: .text(.init("xml"), charset: .utf8))

private func validateUserAndSalt<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Database.User, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Database.User, Database.User.RssSalt, Z>, Data> {

    return { conn in
      guard get1(conn.data).rssSalt == get2(conn.data) else {
        // todo: redirect to atom feed with error summary
        return conn
          |> redirect(to: .home)
      }
      return conn.map(const(get1(conn.data)))
        |> middleware
    }
}

private func trackFeedRequest<I>(_ conn: Conn<I, Database.User>) -> IO<Conn<I, Database.User>> {

  return Current.database.createFeedRequestEvent(
    conn.request.allHTTPHeaderFields?["Referer"],
    .privateEpisodesFeed,
    conn.request.allHTTPHeaderFields?["User-Agent"],
    conn.data.id
    )
    .withExcept(notifyError(subject: "Create Feed Request Event Failed"))
    .run
    .map { _ in conn }
}

private let feedView = View<Database.User> { user -> [Node] in
  [
    .text(
      unsafeUnencodedString(
        """
        <?xml version="1.0" encoding="utf-8"?>
        """
      )
    ),
    node(
      "feed",
      [
        xmlns("http://www.w3.org/2005/Atom"),
        attribute("xmlns:itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd"),
        attribute("xmlns:rawvoice", "http://www.rawvoice.com/rawvoiceRssModule/"),
        attribute("xmlns:dc", "http://purl.org/dc/elements/1.1/"),
        attribute("xmlns:media", "http://www.rssboard.org/media-rss"),
        attribute("version", "2.0"),
      ],
      [
        node(
          "channel",
          [
            node("title", [text("Point-Free Videos (Private feed for \(user.email.rawValue))")]),
            node("link", [text( url(to: .account(.rss(userId: user.id, rssSalt: user.rssSalt))) )]),
            node("language", ["en-US"]),
            node("itunes:author", [text("Brandon Williams & Stephen Celis")]),
            node("itunes:subtitle", ["todo"]),
            node("itunes:summary", ["todo"]),
            node("description", []),
            node("itunes:explicit", ["no"]),
            node(
              "itunes:owner",
              [
                node("itunes:name", [text("Brandon Williams & Stephen Celis")]),
                node("itunes:email", ["support@pointfree.co"])
              ]
            ),
            node(
              "itunes:category",
              [attribute("text", "Technology") as Attribute<Void>],
              [node("itunes:category", ["Software How-To"])]
            ),
            node(
              "itunes:category",
              [attribute("text", "Education") as Attribute<Void>],
              [node("itunes:category", ["Training"])]
            ),
            node("copyright", ["Copyright Point-Free, Inc. 2018"]),
            node("itunes:type", ["episodic"]),
            node(
              "itunes:image",
              [attribute("href", "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg") as Attribute<Void>],
              []
            )
            ] + items(for: user)
        )
      ]
    )
  ]
}

private func items(for user: Database.User) -> [Node] {
  return [
    Current
      .episodes()
      .filter { $0.sequence != 0 }
      .sorted(by: their(^\.sequence, >))[1]
  ]
  .compactMap(id)
  .map { item(for: $0, user: user) }
}

private func item(for episode: Episode, user: Database.User) -> Node {
  return node(
    "item",
    [
      node("title", [text("\(episode.sequence): “\(episode.title)”")]),
      node("dc:creator", ["Brandon Williams"]),
      node("dc:creator", ["Stephen Celis"]),
      node("pubDate", [text(rssDateFormatter.string(from: episode.publishedAt))]),
      node("link", [text(url(to: .episode(.left(episode.slug))))]),
      node("guid", [text(url(to: .episode(.left(episode.slug))))]),
      node("description", [text(episode.blurb)]),
      node("itunes:author", [text("Brandon Williams & Stephen Celis")]),
      node("itunes:subtitle", [text(episode.blurb)]),
      node("itunes:summary", [text(episode.blurb)]),
      node("itunes:explicit", ["no"]),
      node("itunes:duration", [text(timestampLabel(for: episode.length))]),
      node("itunes:image", [text(episode.itunesImage ?? "")]),
      node("itunes:season", ["1"]),
      node("itunes:episode", [text("\(episode.sequence)")]),
      node("itunes:title", [text("\(episode.sequence): “\(episode.title)”")]),
      node("itunes:episodeType", ["full"]),
      node("itunes:content", ["todo"]),
      node(
        "enclosure",
        [
          attribute("url", episode.downloadVideoUrl ?? "") as Attribute<Void>,
          attribute("length", "\(episode.length)"),
          attribute("type", "video/mpeg"),
          ],
        []
      ),
      node(
        "media:content",
        [
          attribute("url", episode.downloadVideoUrl ?? "") as Attribute<Void>,
          attribute("length", "\(episode.length)"),
          attribute("type", "video/mpeg"),
          attribute("medium", "video"),
          ],
        [
          node(
            "media:title",
            [text("\(episode.sequence): “\(episode.title)”")]
          )
        ]
      )
    ]
  )
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
