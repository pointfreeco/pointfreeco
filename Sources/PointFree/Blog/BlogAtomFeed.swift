import Foundation
import Html
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Syndication
import Views

let blogAtomFeedResponse =
  writeStatus(.ok)
    >=> respond(feedView, contentType: .application(.atom))

private func feedView(posts: [BlogPost]) -> [Node] {
  return atomLayout(
    atomFeed: AtomFeed(
      atomUrl: url(to: .feed(.atom)),
      author: AtomAuthor(
        email: "support@pointfree.co",
        name: "Point-Free"
      ),
      entries: posts.map(atomEntry(for:)),
      siteUrl: url(to: .blog(.index)),
      title: "Point-Free Pointers"
    )
  )
}

private func atomEntry(for post: BlogPost) -> AtomEntry {
  return AtomEntry(
    content: blogPostContentView(post),
    siteUrl: url(to: .blog(.show(slug: post.slug))),
    title: post.title,
    updated: post.publishedAt
  )
}
