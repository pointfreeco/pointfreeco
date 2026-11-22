import Foundation

extension BlogPost {
  public static let post0238_CyberMonday = Self(
    author: .pointfree,
    blurb: """
      Our Black Friday sale is extended through Cyber Monday! Save 30% on the first year of a new \
      Point-Free membership, including Point-Free Max.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/15bfbbf3-a45d-4d8f-9fdd-f4bfa9e00b00/public",
    hideFromSlackRSS: true,
    id: 238,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-30")!,
    title: "CYBER MONDAY: Save 30% on Point-Free"
  )
}
