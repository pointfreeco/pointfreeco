import Foundation

public let post0121_MacroBonanza = BlogPost(
  author: .pointfree,
  blurb: """
    This week was dedicated to the Macro Bonanza, where we showed how Swift's macro system allowed 
    us to greatly simplify 4 of our popular libraries, as well as improve their ergonomics and
    increase their power. Join us for an overview!
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 121),
  coverImage: nil,
  id: 121,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-17")!,
  title: "Macro Bonanza"
)
