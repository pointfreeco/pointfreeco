import Foundation

extension Episode {
  public static let ep345_sync = Episode(
    blurb: """
      We add advanced sharing functionality to our reminders app by fetching and displaying \
      participant information, all without hitting CloudKit servers by leveraging SQLiteData's \
      metadata, instead. Along the way we will explore two powerful tools to simplify our app: \
      database "views" and the `@DatabaseFunction` macro.
      """,
    codeSampleDirectory: "0345-sync-pt5",
    exercises: _exercises,
    id: 345,
    length: 56 * 60 + 19,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-11-10")!,
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
    sequence: 345,
    subtitle: "Participants",
    title: "CloudKit Sync",
    trailerVideo: Video(
      bytesLength: 35_200_000,
      downloadUrls: .s3(
        hd1080: "0345-trailer-1080p-c40d1e16f67f444399dcaf6008ae1388",
        hd720: "0345-trailer-1080p-c40d1e16f67f444399dcaf6008ae1388",
        sd540: "0345-trailer-1080p-c40d1e16f67f444399dcaf6008ae1388"
      ),
      id: "94b809f771086e05e13af6b817dc2821"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
