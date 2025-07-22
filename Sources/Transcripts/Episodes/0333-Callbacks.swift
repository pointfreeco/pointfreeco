import Foundation

extension Episode {
  public static let ep333_callbacks = Episode(
    blurb: """
      We conclude our series on modern persistence and callbacks by showing how we can call back \
      to _Swift_ from a database trigger. We will take advantage of this by improving the \
      ergonomics of two features in our Reminders application.
      """,
    codeSampleDirectory: "0333-callbacks-pt4",
    exercises: _exercises,
    id: 333,
    length: 34 * 60 + 5,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-07-28")!,
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
    sequence: 333,
    subtitle: "Advanced Triggers",
    title: "Persistence Callbacks",
    trailerVideo: Video(
      bytesLength: 43_100_000,
      downloadUrls: .s3(
        hd1080: "0333-trailer-1080p-72ac9ac5cf26445a9c2a0eace92ac025",
        hd720: "0333-trailer-1080p-72ac9ac5cf26445a9c2a0eace92ac025",
        sd540: "0333-trailer-1080p-72ac9ac5cf26445a9c2a0eace92ac025"
      ),
      id: "7a941ece544768edea3b377cb4294ac3"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
