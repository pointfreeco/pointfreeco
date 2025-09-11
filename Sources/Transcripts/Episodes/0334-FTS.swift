import Foundation

extension Episode {
  public static let ep334_fts = Episode(
    blurb: """
      Search is a natural feature to add to an app once your user has stored a whole bunch of \
      data. We will tackle the problem from the perspective of modern persistence using SQLite as \
      your data store by adding a simple search feature to our rewrite of Apple's Reminders app.
      """,
    codeSampleDirectory: "0334-fts-pt1",
    exercises: _exercises,
    id: 334,
    length: 24 * 60 + 0,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-08-11")!,
    references: [
      Reference(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sqlite-data",
        title: "SQLiteData"
      ),
      Reference(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 334,
    subtitle: "The Basics",
    title: "Modern Search",
    trailerVideo: Video(
      bytesLength: 46_700_000,
      downloadUrls: .s3(
        hd1080: "0334-trailer-1080p-592577e458f14af4aefe7b1ed83d9375",
        hd720: "0334-trailer-1080p-592577e458f14af4aefe7b1ed83d9375",
        sd540: "0334-trailer-1080p-592577e458f14af4aefe7b1ed83d9375"
      ),
      id: "9da6b9701779a8b9dea5d81027af0933"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
