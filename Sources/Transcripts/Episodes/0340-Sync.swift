import Foundation

extension Episode {
  public static let ep340_sync = Episode(
    blurb: """
      We show how to add iCloud synchronization to the persistence layer of an existing SQLite \
      application by using SQLiteData. While SQLiteData's CloudKit tools can be configured with a \
      single line of code, one must still prepare their database schema to be compatible and \
      durable when it comes to synchronizing across multiple devices and versions.
      """,
    codeSampleDirectory: "0340-sync-pt1",
    exercises: _exercises,
    id: 340,
    length: 45 * 60 + 49,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-10-06")!,
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
    sequence: 340,
    subtitle: "Preparing an Existing App",
    title: "CloudKit Sync",
    trailerVideo: Video(
      bytesLength: 73_500_000,
      downloadUrls: .s3(
        hd1080: "0340-trailer-1080p-fa4ba575da574c75847dcf35e2b2114f",
        hd720: "0340-trailer-1080p-fa4ba575da574c75847dcf35e2b2114f",
        sd540: "0340-trailer-1080p-fa4ba575da574c75847dcf35e2b2114f"
      ),
      id: "980fd77de541510d8f2e14f270376791"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
