import Foundation
import Html
import HttpPipeline
import Prelude
import View

let blogAtomFeedResponse =
  writeStatus(.ok)
    >=> respond(feedView, contentType: .application(.atom))

private let feedView = View<[BlogPost]> { posts in
  atomLayout.view(
    AtomFeed(
      author: AtomAuthor(
        email: "support@pointfree.co",
        name: "Point-Free"
      ),
      entries: posts.map(atomEntry(for:)),
      atomUrl: url(to: .feed(.atom)),
      siteUrl: url(to: .blog(.index)),
      title: "Point-Free Pointers"
    )
  )
}

private func atomEntry(for post: BlogPost) -> AtomEntry {
  return AtomEntry(
    title: post.title,
    siteUrl: url(to: .blog(.show(post))),
    updated: post.publishedAt,
    content: blogPostContentView.view(post)
  )
}
