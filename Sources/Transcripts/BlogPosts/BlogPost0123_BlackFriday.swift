import Foundation

public let post0123_BlackFriday = BlogPost(
  author: .pointfree,
  blurb: """
    We only do this a few times a year, but we are offering a 30% discount for the first year of a
    new Point-Free subscription! Get instant access to all past 259 episodes instantly, as well as
    access to everything we have planned for 2024.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 123),
  coverImage: nil,
  hideFromSlackRSS: true,
  id: 123,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-22")!,
  title: "30% Off Point-Free for Black Friday!"
)
