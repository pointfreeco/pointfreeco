import Foundation

extension BlogPost {
  public static let post0167_WereLive = Self(
    author: .pointfree,
    blurb: """
      Our live stream will be starting soon. Tune in now to watch us discuss our popular Sharing \
      library, and we will release a brand new open source project, live! We will also give a \
      sneak peek at our upcoming series, take questions from our viewers, and give away 7 \
      yearly subscriptions to one of our viewers.
      """,
    coverImage: nil,
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-02-15")!),
    hideFromSlackRSS: false,
    id: 167,
    publishedAt: yearMonthDayFormatter.date(from: "2024-02-14")!
      .addingTimeInterval(60 * 60 * 16),  // 4:00pm GMT
    title: "We’re going live soon!"
  )
}
