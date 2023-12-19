import Dependencies
import Foundation
import FunctionalCss
import Html
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Syndication
import Views

let blogAtomFeedResponse =
  writeStatus(.ok)
  >=> respond(feedView, contentType: .application(.atom))

private func feedView(posts: [BlogPost]) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return atomLayout(
    atomFeed: AtomFeed(
      atomUrl: siteRouter.url(for: .feed(.atom)),
      author: AtomAuthor(
        email: "support@pointfree.co",
        name: "Point-Free"
      ),
      entries: posts.map(atomEntry(for:)),
      siteUrl: siteRouter.url(for: .blog()),
      title: "Point-Free Pointers"
    )
  )
}

private func atomEntry(for post: BlogPost) -> AtomEntry {
  @Dependency(\.siteRouter) var siteRouter

  return AtomEntry(
    content: .p(.text(post.blurb)),
    siteUrl: siteRouter.url(for: .blog(.show(slug: post.slug))),
    title: post.title,
    updated: post.publishedAt
  )
}
