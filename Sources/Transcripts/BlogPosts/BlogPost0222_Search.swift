import Foundation

extension BlogPost {
  public static let post0222_search = Self(
    author: .pointfree,
    blurb: """
      Point-Free now has episode search! Every word of every one of our 377 episodes is \
      indexed—dialogue _and_ code—so you can easily revisit our lessons with a quick query.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 222,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-14")!,
    title: "Announcing: Search"
  )
}
