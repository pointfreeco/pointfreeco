import Foundation

public let post0110_WritingReliableAsyncTests = BlogPost(
  author: .pointfree,
  blurb: """
    Swift makes it easy to write powerful, succinct async code, but how easy is it to test that
    code? We show how seemingly reasonable async code can be nearly impossible to test, and then
    how what can be done about it.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 110),
  coverImage: nil,
  id: 110,
  publishedAt: yearMonthDayFormatter.date(from: "2023-07-19")!,
  title: "Reliably testing async code in Swift"
)
