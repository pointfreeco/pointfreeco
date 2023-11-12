import Foundation

public let post0118_MacroBonanza = BlogPost(
  author: .pointfree,
  blurb: """
    We are releasing a major macro update to our Composable Architecture library. A brand new
    `@Reducer` macro has been introduced that can automate some of the aspects of building features
    in the library, greatly simplify the library's tools, and even ensure the library is being used
    correctly at compile time.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 118),
  coverImage: nil,  // TODO
  id: 118,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-14")!,
  title: "Macro Bonanza: Composable Architecture"
)
