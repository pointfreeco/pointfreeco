import Foundation

extension Episode {
  public static let ep339_fts = Episode(
    blurb: """
      We round out modern search by diving into FTS5's query syntax language. We'll learn how it \
      works, how to escape terms sent directly by the user, and we'll introduce SwiftUI search \
      tokens that can refine a query by term proximity and tags.
      """,
    codeSampleDirectory: "0339-fts-pt6",
    exercises: _exercises,
    id: 339,
    length: 38 * 60 + 58,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-09-22")!,
    references: [
      Reference(
        blurb: """
          FTS5 is an SQLite virtual table module that provides full-text search functionality to \
          database applications.
          """,
        link: "https://www.sqlite.org/fts5.html",
        title: "SQLite FTS5 Extension"
      ),
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
    sequence: 339,
    subtitle: "Syntax & Tokenization",
    title: "Modern Search",
    trailerVideo: Video(
      bytesLength: 25_800_000,
      downloadUrls: .s3(
        hd1080: "0339-trailer-1080p-c9b53595d970456bb1055e833aff8e50",
        hd720: "0339-trailer-1080p-c9b53595d970456bb1055e833aff8e50",
        sd540: "0339-trailer-1080p-c9b53595d970456bb1055e833aff8e50"
      ),
      id: "95893f4e723d934e3090e49ffb4c8619"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
