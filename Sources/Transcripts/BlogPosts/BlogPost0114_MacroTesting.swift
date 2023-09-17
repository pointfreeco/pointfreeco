import Foundation

public let post0114_MacroTesting = BlogPost(
  author: .pointfree,
  blurb: """
    With the release of Swift 5.9 and its new macros feature, we are excited to announce a brand \
    new open source library: Macro Testing. It includes powerful tools for writing tests for your \
    macros.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 114),
  coverImage:
    "https://pointfreeco-blog.s3.amazonaws.com/posts/0114-macro-testing/macro-testing.gif",
  id: 114,
  publishedAt: yearMonthDayFormatter.date(from: "2023-09-18")!,
  title: "A new tool for testing macros in Swift"
)
