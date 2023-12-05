import Foundation

public let post0124_CyberMonday = BlogPost(
  author: .pointfree,
  blurb: """
    We only do this a few times a year, but we are offering a 30% discount for the first year of a
    new Point-Free subscription! Get instant access to all past 260 episodes instantly, as well as
    access to everything we have planned for 2024.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 124),
  coverImage: nil,
  hidden: true,
  hideFromSlackRSS: true,
  id: 124,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-27")!,
  title: "30% off Point-Free for Cyber Monday!"
)
