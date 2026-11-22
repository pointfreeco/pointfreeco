import Foundation

extension BlogPost {
  public static let post0236_BlackFriday = Self(
    author: .pointfree,
    blurb: """
      We're offering a 30% discount for the first year of a new Point-Free membership, including \
      Point-Free Max! Get instant access to all past episodes, as well as everything we have \
      planned for 2027.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/15bfbbf3-a45d-4d8f-9fdd-f4bfa9e00b00/public",
    hidden: .yes,
    hideFromSlackRSS: true,
    id: 236,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-25")!,
    title: "BLACK FRIDAY: Save 30% on Point-Free"
  )
}
