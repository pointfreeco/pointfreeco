import Foundation

public let post0128_EOYSale = BlogPost(
  author: .pointfree,
  blurb: """
    Get 25% off for the first year of subscription with our end-of-year sale. Get access to all past
    episodes, as well as everything we have planned for next year!
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 128),
  coverImage: nil,
  hidden: true,
  hideFromSlackRSS: true,
  id: 128,
  publishedAt: yearMonthDayFormatter.date(from: "2023-12-26")!,
  title: "25% off Point-Free"
)
