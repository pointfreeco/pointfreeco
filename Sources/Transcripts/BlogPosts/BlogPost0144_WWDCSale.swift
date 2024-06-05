import Foundation

public let post0144_WWDCSale = BlogPost(
  author: .pointfree,
  blurb: """
    Get 25% off the first year of your Point-Free subscription to celebrate 10 years of Swift \
    and the beginning of WWDC 2024!
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 144),
  coverImage: nil,
  hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-06-18")!),
  id: 144,
  publishedAt: yearMonthDayFormatter.date(from: "2024-06-12")!,
  title: "10 years of Swift, 25% off Point-Free 🎉"
)
