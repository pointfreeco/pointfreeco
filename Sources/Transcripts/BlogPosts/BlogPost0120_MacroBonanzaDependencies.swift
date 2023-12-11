import Foundation

public let post0120_MacroBonanza = BlogPost(
  author: .pointfree,
  blurb: """
    In part 4, and the final part, of our Macro Bonanza we demonstrate how macros allow us to
    better design dependencies when using our popular Dependencies library. Large amounts of
    boilerplate code can be automatically generated for us, and the ergonomics of our dependencies
    can be greatly improved.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 120),
  coverImage: nil,
  id: 120,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-16")!,
  title: "Macro Bonanza: Dependencies"
)
