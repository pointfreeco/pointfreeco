import Foundation

extension BlogPost {
  public static let post0222_search = Self(
    author: .pointfree,
    blurb: """
      Point-Free now has full-text search! Every word of every one of our 377 episodes is \
      indexed—prose, section titles, and even the code we write on screen—with results that \
      deep-link to the exact moment in the video.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 222,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-14")!,
    title: "Announcing: Search"
  )
}
