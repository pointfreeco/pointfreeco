import Foundation

extension BlogPost {
  public static let post0193_CyberMonday = Self(
    author: .pointfree,
    blurb: """
      We're offering a 30% discount for the first year of a new Point-Free subscription! Get \
      instant access to all past 343 episodes instantly, as well as access to everything we have \
      planned for 2026.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/9045fa26-782a-4c9f-4ae4-0b8f0fa8a300/public",
    hidden: .yes,
    hideFromSlackRSS: true,
    id: 193,
    publishedAt: yearMonthDayFormatter.date(from: "2025-12-01")!,
    title: "CYBER MONDAY: Save 30% on Point-Free"
  )
}
