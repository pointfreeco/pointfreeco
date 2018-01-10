import Foundation
import Html
import HttpPipeline
import MediaType
import Prelude

let atomFeedResponse =
  writeStatus(.ok)
    >-> respond(pointFreeFeed, contentType: .html)

let pointFreeFeed = View<[Episode]> { episodes in
  atomLayout.view(
    AtomFeed(
      author: AtomAuthor(
        email: "support@pointfree.co",
        name: "Point-Free"
      ),
      entries: episodes.map(atomEntry(for:)),
      atomUrl: url(to: .feed(.atom)),
      siteUrl: "/", // FIXME url(to: .root),
      title: "Point-Free"
    )
  )
}

// TODO: swift-web
public func respond<A>(_ view: View<A>, contentType: MediaType = .html) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return { conn in
    conn |> respond(body: view.rendered(with: conn.data), contentType: contentType)
  }
}

private func atomEntry(for episode: Episode) -> AtomEntry {
  return AtomEntry(
    title: episode.title,
    siteUrl: url(to: .episode(.left(episode.slug))),
    updated: episode.publishedAt,
    content: []
  )
}
