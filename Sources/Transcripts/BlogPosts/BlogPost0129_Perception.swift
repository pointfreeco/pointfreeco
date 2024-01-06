import Foundation

public let post0129_Perception = BlogPost(
  author: .pointfree,
  blurb: """
    We have back-ported Swift 5.9's observation tools to work on Apple platforms going back almost
    4 years ago! Start using it today even if you cannot target iOS 17.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 129),
  coverImage: nil,
  hidden: false,
  hideFromSlackRSS: false,
  id: 129,
  publishedAt: yearMonthDayFormatter.date(from: "2024-01-09")!,
  title: "Perception: A back-port of @Observable"
)
