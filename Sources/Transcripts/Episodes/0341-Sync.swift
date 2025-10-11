import Foundation

extension Episode {
  public static let ep341_sync = Episode(
    blurb: """
      With our database migrated, it's time to take the `SyncEngine` for a spin to see how it \
      seamlessly synchronizes data to and from iCloud, how it resolves conflicts when records are \
      edited and deleted from multiple devices, and even how records are synchronized from \
      different versions of the application and database schema.
      """,
    codeSampleDirectory: "0341-sync-pt2",
    exercises: _exercises,
    id: 341,
    length: 42 * 60 + 39,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-10-13")!,
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
      Reference(
        blurb: """
          In distributed computing, a conflict-free replicated data type (CRDT) is a data \
          structure that is replicated across multiple computers in a network.
          """,
        link: "https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type",
        title: "Conflict-free replicated data type (CRDT)"
      ),
    ],
    sequence: 341,
    subtitle: "The SyncEngine",
    title: "CloudKit Sync",
    trailerVideo: Video(
      bytesLength: 34_500_000,
      downloadUrls: .s3(
        hd1080: "0341-trailer-1080p-5c77829ae12e4a818130d2a6acfe2b39",
        hd720: "0341-trailer-1080p-5c77829ae12e4a818130d2a6acfe2b39",
        sd540: "0341-trailer-1080p-5c77829ae12e4a818130d2a6acfe2b39"
      ),
      id: "23b751c2a51d1b4a5dfd0e42b9d19640"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
