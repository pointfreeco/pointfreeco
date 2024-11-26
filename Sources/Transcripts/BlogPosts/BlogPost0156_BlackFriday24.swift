import Foundation

extension BlogPost {
  public static let post0156_BlackFriday2024 = Self(
    author: .pointfree,
    blurb: """
      Black Friday is here and it's time to save big on Point-Free! Subscribe today at a 30%
      discount and get instant access to almost 200 hours of advanced Swift content that will help
      you level up your career.
      """,
    coverImage: nil,
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-12-02")!),
    hideFromSlackRSS: true,
    id: 156,
    publishedAt: yearMonthDayFormatter.date(from: "2024-11-29")!,
    title: "Black Friday = 30% Off Point-Free!"
  )
}
