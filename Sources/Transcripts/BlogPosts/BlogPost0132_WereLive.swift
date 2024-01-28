import Foundation

public let post0132_WereLive = BlogPost(
  author: .pointfree,
  blurb: """
    Our live stream will be starting soon. Tune in now to watch us discuss the recently released \
    observation tools in the Composable Architecture, and we will announce some brand new \
    features that have never been discussed before. 🫢
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 132),
  coverImage: nil,
  hidden: false,
  hideFromSlackRSS: false,
  id: 132,
  publishedAt: yearMonthDayFormatter.date(from: "2024-02-05")!
    .addingTimeInterval(60 * 60 * 17 - 60 * 40),  // 4:20pm GMT
  title: "We’re live!"
)
