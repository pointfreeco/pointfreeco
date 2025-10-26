import Foundation

extension Episode {
  public static let ep343_sync = Episode(
    blurb: """
      We add iCloud sharing and collaboration to our reminders app rewrite, so that multiple users
      can edit the same reminders list. It takes surprisingly little code, no changes to our
      feature's logic, and handles all manner of conflict resolution and more.
      """,
    codeSampleDirectory: "0343-sync-pt4",
    exercises: _exercises,
    id: 343,
    length: 35 * 60 + 46,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-10-28")!,
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
    sequence: 343,
    subtitle: "Sharing",
    title: "CloudKit Sync",
    trailerVideo: Video(
      bytesLength: 31_000_000,
      downloadUrls: .s3(
        hd1080: "0343-trailer-1080p-d36f07eb118b409c9b9fd61de33f3762",
        hd720: "0343-trailer-1080p-d36f07eb118b409c9b9fd61de33f3762",
        sd540: "0343-trailer-1080p-d36f07eb118b409c9b9fd61de33f3762"
      ),
      id: "5a9a6e4a784e6fd72dae93323c71e936"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
