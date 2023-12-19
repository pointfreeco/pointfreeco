import Foundation

public let post0127_EOYSale = BlogPost(
  author: .pointfree,
  blurb: """
    Through the new year, we're offering personal Point-Free subscriptions for 25% off the first \
    year!
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 127),
  coverImage: nil,
  id: 127,
  publishedAt: yearMonthDayFormatter.date(from: "2023-12-20")!,
  title: "End-of-year sale: 25% off Point-Free"
)
