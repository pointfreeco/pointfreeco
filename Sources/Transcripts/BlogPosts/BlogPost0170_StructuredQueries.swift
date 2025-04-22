import Foundation

extension BlogPost {
  public static let post0170_StructuredQueries = Self(
    author: .pointfree,
    blurb: """
      Replace SwiftData with a fast, ergonomic and lightweight suite of tools powered by SQL. \
      It provides APIs similar to @Model, @Query and #Predicate, but is tuned for direct access \
      to the underlying database instead of abstracting it away from you.
      """,
    coverImage: "https://pointfreeco-production.s3.amazonaws.com/posters/structured-queries.png",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 170,
    publishedAt: yearMonthDayFormatter.date(from: "2025-04-22")!,
    title: "A fast, lightweight replacement for SwiftData"
  )
}
