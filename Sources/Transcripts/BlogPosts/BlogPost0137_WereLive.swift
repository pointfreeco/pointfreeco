import Foundation

public let post0137_WereLive = BlogPost(
  author: .pointfree,
  blurb: """
    Our live stream will be starting soon. Tune in now to watch us discuss the recently released \
    observation tools in the Composable Architecture, and we will announce some brand new \
    features that have never been discussed before. 🫢
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 137),
  coverImage: nil,
  hidden: false,
  hideFromSlackRSS: false,
  id: 137,
  publishedAt: yearMonthDayFormatter.date(from: "2024-05-09")!,
  title: "We’re live!"
)
