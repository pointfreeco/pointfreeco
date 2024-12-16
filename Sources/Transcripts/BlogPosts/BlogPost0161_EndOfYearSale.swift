import Foundation

extension BlogPost {
  public static let post0161_EndOfYearSale = Self(
    author: .pointfree,  // todo
    blurb: """
      Through the new year, we're offering personal Point-Free subscriptions for 25% off the first \
      year!
      """,
    coverImage: nil,
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-12-23")!),
    hideFromSlackRSS: true,
    id: 161,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-18")!,
    title: "End-of-year sale: 25% off Point-Free"
  )
}
