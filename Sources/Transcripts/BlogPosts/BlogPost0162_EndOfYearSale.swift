import Foundation

extension BlogPost {
  public static let post0162_EndOfYearSale = Self(
    author: .pointfree,
    blurb: """
      Through the new year, we're offering personal Point-Free subscriptions for 25% off the first \
      year!
      """,
    coverImage: nil,
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2025-01-05")!),
    hideFromSlackRSS: true,
    id: 162,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-27")!,
    title: "End-of-year sale: 25% off Point-Free"
  )
}
