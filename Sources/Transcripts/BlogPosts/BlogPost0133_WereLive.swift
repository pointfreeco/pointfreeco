import Foundation

extension BlogPost {
  public static let post0133_WereLive = Self(
    author: .pointfree,
    blurb: """
      Our live stream will be starting soon. Tune in now to watch us discuss the recently released \
      observation tools in the Composable Architecture, and we will announce some brand new \
      features that have never been discussed before. 🫢
      """,
    coverImage: nil,
    hidden: .yes,
    hideFromSlackRSS: false,
    id: 133,
    publishedAt: yearMonthDayFormatter.date(from: "2024-02-12")!
      .addingTimeInterval(60 * 60 * 17 - 60 * 40),  // 4:20pm GMT
    title: "We’re live!"
  )
}
