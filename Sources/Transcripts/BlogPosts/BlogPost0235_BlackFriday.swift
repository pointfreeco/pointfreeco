import Foundation

extension BlogPost {
  public static let post0235_BlackFriday = Self(
    author: .pointfree,
    blurb: """
      We're offering a 30% discount for the first year of a new Point-Free membership, including \
      Point-Free Max! Get instant access to all past episodes, as well as everything we have \
      planned for 2027.
      """,
    coverImage: nil,  // TODO
    hideFromSlackRSS: true,
    id: 235,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-17")!,
    title: "BLACK FRIDAY: Save 30% on Point-Free"
  )
}
