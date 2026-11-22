import Foundation

extension Episode {
  public static let ep388_notifications = Episode(
    blurb: """
      With our new main actor notifications implemented, we embark on our goal of building a \
      cross-isolation asynchronous notification system in which all observers can be awaited by \
      the poster.
      """,
    codeSampleDirectory: "0388-notifications-pt4",
    exercises: _exercises,
    id: 388,
    length: 25 * 60 + 48,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-23")!,
    references: [
    ],
    sequence: 388,
    socialImage: nil,
    subtitle: "Async Notifications",
    title: "Designing for Isolation 2",
    trailerVideo: Video(
      bytesLength: 42_319_173,
      downloadUrls: .s3(
        hd1080: "0388-trailer-1080p-4e9dcc430d0442a1beeed87a96910857",
        hd720: "0388-trailer-1080p-4e9dcc430d0442a1beeed87a96910857",
        sd540: "0388-trailer-1080p-4e9dcc430d0442a1beeed87a96910857"
      ),
      id: "187e35eec8a81162ff1930d11a62471f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
