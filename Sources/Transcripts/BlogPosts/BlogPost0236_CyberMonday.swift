import Foundation

extension BlogPost {
  public static let post0236_CyberMonday = Self(
    author: .pointfree,
    blurb: """
      Our Black Friday sale is extended through Cyber Monday! Save 30% on the first year of a new \
      Point-Free membership, including Point-Free Max.
      """,
    coverImage: nil,  // TODO
    hideFromSlackRSS: true,
    id: 236,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-30")!,
    title: "CYBER MONDAY: Save 30% on Point-Free"
  )
}
