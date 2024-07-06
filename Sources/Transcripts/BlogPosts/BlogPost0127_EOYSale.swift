import Foundation

extension BlogPost {
  public static let post0127_EOYSale = Self(
    author: .pointfree,
    blurb: """
      Through the new year, we're offering personal Point-Free subscriptions for 25% off the first \
      year!
      """,
    coverImage: nil,
    hidden: .yes,
    hideFromSlackRSS: true,
    id: 127,
    publishedAt: yearMonthDayFormatter.date(from: "2023-12-20")!,
    title: "End-of-year sale: 25% off Point-Free"
  )
}
