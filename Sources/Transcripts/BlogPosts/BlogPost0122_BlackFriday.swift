import Foundation

public let post0122_BlackFriday = BlogPost(
  author: .pointfree,
  blurb: """
    We're offering a 30% discount for the first year of a new Point-Free subscription! Get instant
    access to all past 259 episodes instantly, as well as access to everything we have planned
    for 2024.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 122),
  coverImage: nil,
  hideFromRSS: true,
  id: 122,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-20")!,
  title: "Black Friday Sale: 30% Off Point-Free"
)
