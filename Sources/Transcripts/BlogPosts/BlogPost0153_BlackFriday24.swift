import Foundation

extension BlogPost {
  public static let post0153_BlackFriday2024 = Self(
    author: .pointfree,
    blurb: """
      We're offering a 30% discount for the first year of a new Point-Free subscription! Get \
      instant access to all past 303 episodes instantly, as well as access to everything we have \
      planned for 2025.
      """,
    coverImage: nil,
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-11-21")!),
    hideFromSlackRSS: true,
    id: 153,
    publishedAt: yearMonthDayFormatter.date(from: "2024-11-18")!,
    title: "Black Friday Sale: 30% Off Point-Free"
  )
}
