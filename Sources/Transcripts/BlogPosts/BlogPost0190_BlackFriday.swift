import Foundation

extension BlogPost {
  public static let post0190_BlackFriday = Self(
    author: .pointfree,  
    blurb: """
      We're offering a 30% discount for the first year of a new Point-Free subscription! Get \
      instant access to all past 303 episodes instantly, as well as access to everything we have \
      planned for 2026.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 190,
    publishedAt: yearMonthDayFormatter.date(from: "2025-11-20")!,
    title: "BLACK FRIDAY: Save 30% on Point-Free"
  )
}
