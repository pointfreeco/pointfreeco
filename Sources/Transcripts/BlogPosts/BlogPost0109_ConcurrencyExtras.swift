import Foundation

extension BlogPost {
  public static let post0109_ConcurrencyExtras = Self(
    author: .pointfree,
    blurb: """
      Today we are excited to announce a brand new open source library: Concurrency Extras. It \
      includes tools to help make your concurrent Swift code more versatile and more testable.
      """,
    coverImage: nil,
    id: 109,
    publishedAt: yearMonthDayFormatter.date(from: "2023-07-18")!,
    title: "Announcing Concurrency Extras: Useful, testable Swift concurrency."
  )
}
