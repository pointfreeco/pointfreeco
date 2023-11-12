import Foundation

public let post0117_MacroBonanza = BlogPost(
  author: .pointfree,
  blurb: """
    To celebrate the release of Swift macros we are releasing updates to 4 of our popular libraries to greatly simplify and enhance their abilities: CasePaths, SwiftUINavigation, ComposableArchitecture, and Dependencies. Each day this week we will detail how macros have allowed us to massively simplify one of these libraries, and increase their powers, starting with CasePaths.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 117),  
  coverImage: nil,  // TODO
  id: 117,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-13")!,
  title: "Macro Bonanza: Case Paths"
)
