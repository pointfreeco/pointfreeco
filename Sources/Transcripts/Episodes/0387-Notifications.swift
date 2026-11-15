import Foundation

extension Episode {
  public static let ep387_notifications = Episode(
    blurb: """
      Let's build a modern notification center from scratch! We will take what we learned \
      exploring the legacy and newer designs from Foundation, and build new goals on top of it to \
      build a flexible, testable implementation with the most modern concurrency tools.
      """,
    codeSampleDirectory: "0387-notifications-pt3",
    exercises: _exercises,
    id: 387,
    length: 32 * 60 + 39,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-16")!,
    references: [
    ],
    sequence: 387,
    socialImage: nil,
    subtitle: "Modern Notifications",
    title: "Designing for Isolation 2",
    trailerVideo: Video(
      bytesLength: 79_135_524,
      downloadUrls: .s3(
        hd1080: "0387-trailer-1080p-aa9502e529514ca7a3ca3433ee989e9e",
        hd720: "0387-trailer-1080p-aa9502e529514ca7a3ca3433ee989e9e",
        sd540: "0387-trailer-1080p-aa9502e529514ca7a3ca3433ee989e9e"
      ),
      id: "62438e71fc184e2eaa4d4eb13a9a7042"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
