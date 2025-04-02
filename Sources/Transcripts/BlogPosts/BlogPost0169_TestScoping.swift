import Foundation

extension BlogPost {
  public static let post0169_testScoping = Self(
    author: .pointfree,
    blurb: """
      TODO \
      TODO
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 169,
    publishedAt: yearMonthDayFormatter.date(from: "2025-04-02")!,
    title: "New in Swift 6.1: Test Scoping Traits"
  )
}
