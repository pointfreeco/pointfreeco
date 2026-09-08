import Foundation

extension BlogPost {
  public static let post0226_freeWWDC26 = Self(
    author: .pointfree,
    blurb: """
      Our entire WWDC 26 series is now free for everyone to watch. Catch up on 10 episodes \
      covering SwiftUI's new alert and @State APIs, UIKit navigation, and a deep comparison of \
      SwiftData's new tools with SQLiteData.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 226,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-06")!,
    title: "Our WWDC 26 series is now free"
  )
}
