import Foundation

public let post0001_welcome = BlogPost(
  author: nil,
  blurb: """
    Today we are excited to announcement launch of Point-Free Pointers, a blog to supplement our video
    series for all the content we couldn’t fit in. Expect to find regularly postings here that dive
    even deeper into functional programming, showing real world use cases and more!
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 1),
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/common/pfp-social-logo.jpg",
  id: 1,
  publishedAt: .init(timeIntervalSince1970: 1_524_456_062),
  title: "Announcing Point-Free Pointers!"
)
