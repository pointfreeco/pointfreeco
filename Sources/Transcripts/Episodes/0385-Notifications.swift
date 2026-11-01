import Foundation

extension Episode {
  public static let ep385_notifications = Episode(
    blurb: """
      Let's explore _another_ example of designing code with isolation in mind, taking inspiration \
      from notification center. We'll start with a trip down memory lane to see how Swift adopted \
      the original NeXTSTEP implementation, pre-concurrency, and the positives and negatives that \
      came along for the ride.
      """,
    codeSampleDirectory: "0385-notifications-pt1",
    exercises: _exercises,
    id: 385,
    length: 34 * 60 + 42,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-11-02")!,
    references: [
    ],
    sequence: 385,
    socialImage: nil,
    subtitle: "Notifications",
    title: "Designing for Isolation 2",
    trailerVideo: Video(
      bytesLength: 68_500_000,
      downloadUrls: .s3(
        hd1080: "0385-trailer-1080p-734a4f7407744a23933c3d02e0a2b89a",
        hd720: "0385-trailer-1080p-734a4f7407744a23933c3d02e0a2b89a",
        sd540: "0385-trailer-1080p-734a4f7407744a23933c3d02e0a2b89a"
      ),
      id: "361ed003469b8bc9c7141e09db83f728"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
