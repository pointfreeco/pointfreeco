import Foundation

extension Episode {
  public static let ep336_fts = Episode(
    blurb: """
      We start to leverage SQLite's built-in full-text search capabilities to power our feature. \
      We learn about virtual tables, create one that stores the searchable data, populate it with \
      the help of database triggers, and show just how powerful and succinct search can be.
      """,
    codeSampleDirectory: "0336-fts-pt3",
    exercises: _exercises,
    id: 336,
    length: 34 * 60 + 22,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-08-25")!,
    references: [
      Reference(
        blurb: """
          FTS5 is an SQLite virtual table module that provides full-text search functionality to \
          database applications.
          """,
        link: "https://www2.sqlite.org/fts5.html",
        title: "SQLite FTS5 Extension"
      ),
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
    sequence: 336,
    subtitle: "Full-Text Search",
    title: "Modern Search",
    trailerVideo: Video(
      bytesLength: 36_000_000,
      downloadUrls: .s3(
        hd1080: "0336-trailer-1080p-659b42182c5b4276a6ffe97f82d0b5d0",
        hd720: "0336-trailer-1080p-659b42182c5b4276a6ffe97f82d0b5d0",
        sd540: "0336-trailer-1080p-659b42182c5b4276a6ffe97f82d0b5d0"
      ),
      id: "a7fd086a00f802c57b4b541f27aed548"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
