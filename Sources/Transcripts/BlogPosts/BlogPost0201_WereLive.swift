import Foundation

extension BlogPost {
  public static let post0201_WereLive = Self(
    author: .pointfree,
    blurb: """
      Our live stream will be starting very soon. Tune in now to watch us discuss the "Point-Free \
      Way" and a sneak peek of Composable Architecture 2.0. We will also take questions from our \
      viewers, and give away a yearly membership to 8 lucky viewers.
      """,
    coverImage: nil,
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2026-02-06")!),
    hideFromSlackRSS: false,
    id: 201,
    publishedAt: yearMonthDayFormatter.date(from: "2026-02-05")!
      .addingTimeInterval(60 * 60 * 16),  // 4:00pm GMT
    title: "We’re going live soon!"
  )
}
