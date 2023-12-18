import Foundation

public let post0126_YearInReview = BlogPost(
  author: .pointfree,
  blurb: """
    Point-Free year in review: 45 episodes, 200K unique visitors, 4 new open source projects,
    and a whole bunch more!
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 126),
  coverImage: nil,
  id: 126,
  publishedAt: yearMonthDayFormatter.date(from: "2023-12-19")!,
  title: "2023 Year-in-review"
)
