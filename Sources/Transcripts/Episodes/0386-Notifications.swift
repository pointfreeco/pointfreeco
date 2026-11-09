import Foundation

extension Episode {
  public static let ep386_notifications = Episode(
    blurb: """
      We explore the revamped notifications API for modern Swift concurrency to see how they stack \
      up against the preconcurrency APIs. In fact it's two parallel set of APIs, "async" and "main \
      actor," which work slightly differently for good reasons.
      """,
    codeSampleDirectory: "0386-notifications-pt2",
    exercises: _exercises,
    id: 386,
    length: 35 * 60 + 12,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-09")!,
    references: [
    ],
    sequence: 386,
    socialImage: nil,
    subtitle: "Newer Notifications",
    title: "Designing for Isolation 2",
    trailerVideo: Video(
      bytesLength: 42_700_000,
      downloadUrls: .s3(
        hd1080: "0386-trailer-1080p-8510604d354f42eda4a093eb2ed062e4",
        hd720: "0386-trailer-1080p-8510604d354f42eda4a093eb2ed062e4",
        sd540: "0386-trailer-1080p-8510604d354f42eda4a093eb2ed062e4"
      ),
      id: "2c55438a636b99ab5ac3232eeea9e795"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
