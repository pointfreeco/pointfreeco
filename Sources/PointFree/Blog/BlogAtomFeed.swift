import Foundation
import Html
import HttpPipeline
import Models
import Prelude
import Syndication
import View

let blogAtomFeedResponse =
  writeStatus(.ok)
    >=> respond(feedView, contentType: .application(.atom))

private let feedView = View<[BlogPost]> { posts in
  atomLayout.view(
    AtomFeed(
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
    content: blogPostContentView.view(post),
    siteUrl: url(to: .blog(.show(id: post.id))),
    title: post.title,
    updated: post.publishedAt
  )
}
