import Foundation

extension BlogPost {
  public static let post0198_EndOfYearSale = Self(
    author: .pointfree,
    blurb: """
      Through the new year, we're offering personal Point-Free subscriptions for 25% off the first \
      year!
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/5bae4cd4-eed4-452e-9e5a-55ac84c7c000/public",
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2026-01-05")!),
    hideFromSlackRSS: true,
    id: 198,
    publishedAt: yearMonthDayFormatter.date(from: "2025-12-29")!,
    title: "End-of-year sale: 25% off Point-Free"
  )
}
