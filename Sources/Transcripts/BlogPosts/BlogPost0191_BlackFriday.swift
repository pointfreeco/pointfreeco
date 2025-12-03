import Foundation

extension BlogPost {
  public static let post0191_BlackFriday = Self(
    author: .pointfree,
    blurb: """
      We're offering a 30% discount for the first year of a new Point-Free subscription! Get \
      instant access to all past 343 episodes instantly, as well as access to everything we have \
      planned for 2026.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/0897ce61-28b0-4ebd-11da-29937bfad800/public",
    hidden: .yes,
    hideFromSlackRSS: true,
    id: 191,
    publishedAt: yearMonthDayFormatter.date(from: "2025-11-24")!,
    title: "BLACK FRIDAY: Save 30% on Point-Free"
  )
}
