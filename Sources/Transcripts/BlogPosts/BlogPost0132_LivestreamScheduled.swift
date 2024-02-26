import Foundation

public let post0132_LivestreamRescheduled = BlogPost(
  author: .pointfree,
  blurb: """
    This week we had to cancel our livestream due to historic rain in California and the resulting
    power outages. But things are settled, and we're ready to go live again! Join us on
    February 12th at 9am PST and 5pm GMT.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 132),
  coverImage: nil,
  hidden: true,
  hideFromSlackRSS: false,
  id: 132,
  publishedAt: yearMonthDayFormatter.date(from: "2024-02-08")!,
  title: "Livestream re-scheduled"
)
