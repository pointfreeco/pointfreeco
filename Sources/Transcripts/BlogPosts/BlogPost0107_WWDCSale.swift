import Foundation

public let post0107_WWDCSale = BlogPost(
  author: .pointfree,
  blurb: """
    The year's biggest Apple event is here, and to celebrate we are offering a 25% discount off \
    the first year for first-time subscribers.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 107),
  coverImage: nil,  
  id: 107,
  publishedAt: yearMonthDayFormatter.date(from: "2023-06-01")!,
  title: "WWDC 2023 Sale!"
)
