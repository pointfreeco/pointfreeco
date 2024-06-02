import Foundation

public let post0143_WWDCSale = BlogPost(
  author: .pointfree,
  blurb: """
    Get 25% off the first year of your Point-Free subscription to celebrate 10 years of Swift \
    and the beginning of WWDC 2024!
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 143),
  coverImage: nil,
  hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-06-18")!),
  id: 143,
  publishedAt: yearMonthDayFormatter.date(from: "2024-06-11")!,
  title: "10 years of Swift, 25% off Point-Free 🎉"
)
