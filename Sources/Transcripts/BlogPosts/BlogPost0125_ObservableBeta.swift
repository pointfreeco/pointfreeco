import Foundation

public let post0125_ObservableBeta = BlogPost(
  author: .pointfree,  
  blurb: """
    Today the Composable Architecture crossed 10,000 stars on GitHub, _and_ we are announcing a beta
    preview for the biggest change we have made to the Composable Architecture in its history. We
    are integrating Swift's Observation framework into the library, and it revolutionizes nearly
    every aspect of the library.
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 125),
  coverImage: nil, 
  id: 125,
  publishedAt: yearMonthDayFormatter.date(from: "2023-11-27")!,
  title: "Observable Architecture Beta!"
)
