import Foundation

extension BlogPost {
  public static let post0222_search = Self(
    author: .pointfree,
    blurb: """
      Point-Free now has episode search! Every word of every one of our 377 episodes is \
      indexed—dialogue _and_ code—so you can easily revisit our lessons with a quick query.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/dced5c42-75f5-48f3-db64-724d85f1c000/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 222,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-18")!,
    title: "Announcing: Episode Search"
  )
}
