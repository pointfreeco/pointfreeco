import Foundation

extension Episode {
  public static let ep342_sync = Episode(
    blurb: """
      We introduce a new feature to our reminders app: cover images for each reminders list. This \
      pushes us to create a brand new database table to synchronize, and allows us to demonstrate \
      how SQLiteData seamlessly handles binary blobs by converting them to CloudKit assets under \
      the hood.
      """,
    codeSampleDirectory: "0342-sync-pt3",
    exercises: _exercises,
    id: 342,
    length: 41 * 60 + 46,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-10-20")!,
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
    sequence: 342,
    subtitle: "Assets",
    title: "CloudKit Sync",
    trailerVideo: Video(
      bytesLength: 37_800_000,
      downloadUrls: .s3(
        hd1080: "0342-trailer-1080p-46d4300fbd4d4499b3aaf8b08e783816",
        hd720: "0342-trailer-1080p-46d4300fbd4d4499b3aaf8b08e783816",
        sd540: "0342-trailer-1080p-46d4300fbd4d4499b3aaf8b08e783816"
      ),
      id: "79c0d77ae498df04d39d6cc7556d6e81"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
