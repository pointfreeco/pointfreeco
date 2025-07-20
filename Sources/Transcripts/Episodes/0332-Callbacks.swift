import Foundation

extension Episode {
  public static let ep332_callbacks = Episode(
    blurb: """
      We add a new tag editing feature to our rewrite of Apple's Reminders app to show how we can \
      use database triggers to validate them, and prevent invalid state from ever entering our \
      user's data.
      """,
    codeSampleDirectory: "0332-callbacks-pt3",
    exercises: _exercises,
    id: 332,
    length: 26 * 60 + 42,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-07-21")!,
    references: [
      Reference(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sharing-grdb",
        title: "SharingGRDB"
      ),
      Reference(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 332,
    subtitle: "Validation Triggers",
    title: "Persistence Callbacks",
    trailerVideo: Video(
      bytesLength: 41_800_000,
      downloadUrls: .s3(
        hd1080: "0332-trailer-1080p-c26374d2e2324f418a4665c20a892aec",
        hd720: "0332-trailer-1080p-c26374d2e2324f418a4665c20a892aec",
        sd540: "0332-trailer-1080p-c26374d2e2324f418a4665c20a892aec"
      ),
      id: "0614914289c5f161b9dbfca03e2685b5"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
