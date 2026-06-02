import Foundation

extension BlogPost {
  public static let post0208_WWDC2026Sale = Self(
    author: .pointfree,
    blurb: """
      WWDC 2026 is here, and to celebrate we are offering 30% off the first year of a new \
      Point-Free membership, including Point-Free Max.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/7903112b-fc0b-41d8-4322-c19334bc2b00/public",
    hideFromSlackRSS: true,
    id: 208,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-02")!,
    title: "WWDC Sale: Save 30% on Point-Free"
  )
}
