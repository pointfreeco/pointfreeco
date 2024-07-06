import Foundation

extension BlogPost {
  public static let post0135_SharedStateRelease = Self(
    author: .pointfree,
    blurb: """
      We are releasing powerful state sharing tools in the Composable Architecture that can keep \
      state synchronized between many features, and can persist state to external systems such as \
      user defaults and the file system.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 135,
    publishedAt: yearMonthDayFormatter.date(from: "2024-04-29")!,
    title: "Shared state in the Composable Architecture"
  )
}
