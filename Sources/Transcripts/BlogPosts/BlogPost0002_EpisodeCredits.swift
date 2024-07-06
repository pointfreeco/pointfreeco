import Foundation

extension BlogPost {
  public static let post0002_episodeCredits = Self(
    author: .brandon,
    blurb: """
      Let’s look at a real world use for algebraic data types. We will refactor a data type that \
      is used in the code on this very site so that the invalid states are unrepresentable by \
      the compiler.
      """,
    coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/poster.jpg",
    id: 2,
    publishedAt: .init(timeIntervalSince1970: 1_524_456_062),
    title: "Case Study: Algebraic Data Types"
  )
}
