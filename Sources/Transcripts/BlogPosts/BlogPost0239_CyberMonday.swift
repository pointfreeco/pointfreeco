import Foundation

extension BlogPost {
  public static let post0239_CyberMonday = Self(
    author: .pointfree,
    blurb: """
      Our Black Friday sale is extended through Cyber Monday! Save 30% on the first year of a new \
      Point-Free membership, including Point-Free Max.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/15bfbbf3-a45d-4d8f-9fdd-f4bfa9e00b00/public",
    hidden: .yes,
    hideFromSlackRSS: true,
    id: 239,
    publishedAt: yearMonthDayFormatter.date(from: "2026-12-02")!,
    title: "CYBER MONDAY: Save 30% on Point-Free"
  )
}
