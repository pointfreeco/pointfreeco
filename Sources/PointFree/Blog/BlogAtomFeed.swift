import Dependencies
import Foundation
import Html
import HttpPipeline
import Models
import PointFreeRouter
import Syndication

func blogAtomFeedResponse(
  _ conn: Conn<StatusLineOpen, Void>,
  posts: [BlogPost]
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.renderXml) var renderXml

  return conn.writeStatus(.ok)
    .respond(body: renderXml(feedView(posts: posts)), contentType: .application(.atom))
}

private func feedView(posts: [BlogPost]) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return atomLayout(
    atomFeed: AtomFeed(
      atomUrl: siteRouter.url(for: .feed(.atom)),
      author: AtomAuthor(
        email: "support@pointfree.co",
        name: "Point-Free"
      ),
      entries: posts.map {
        AtomEntry(
          content: .markdownBlock($0.blurb),
          siteUrl: siteRouter.url(for: .blog(.show(slug: $0.slug))),
          title: $0.title,
          updated: $0.publishedAt
        )
      },
      siteUrl: siteRouter.url(for: .blog()),
      title: "Point-Free Pointers"
    )
  )
}
