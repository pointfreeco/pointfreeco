import Foundation

extension Episode {
  public static let ep337_fts = Episode(
    blurb: """
      We're ready to take advantage of some of the superpowers of full-text search, starting with \
      relevancy. We will do a deep dive into the ranking algorithm of SQLite's FTS5 module, \
      explore how the text of a document affects its relevancy score, and how we can tweak these \
      scores based on the column containing a match.
      """,
    codeSampleDirectory: "0337-fts-pt4",
    exercises: _exercises,
    id: 337,
    length: 37 * 60 + 57,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-09-01")!,
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
        link: "https://github.com/pointfreeco/sharing-grdb",
        title: "SharingGRDB"
      ),
      Reference(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 337,
    subtitle: "Relevance & Ranking",
    title: "Modern Search",
    trailerVideo: Video(
      bytesLength: 28_000_000,
      downloadUrls: .s3(
        hd1080: "0337-trailer-1080p-0e3911a1d22744caaaa75d481098a410",
        hd720: "0337-trailer-1080p-0e3911a1d22744caaaa75d481098a410",
        sd540: "0337-trailer-1080p-0e3911a1d22744caaaa75d481098a410"
      ),
      id: "bb6173e2cce307066c852dfda0ab60e2"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
