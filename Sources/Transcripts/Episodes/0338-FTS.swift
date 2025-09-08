import Foundation

extension Episode {
  public static let ep338_fts = Episode(
    blurb: """
      SQLite's full-text search capabilities come with many bells and whistles, including support
      for highlighting search term matches in your UI, as well as generating snippets for where
      matches appear in a larger corpus. We will take these APIs for a spin and enhance our
      Reminders search UI.
      """,
    codeSampleDirectory: "0338-fts-pt5",
    exercises: _exercises,
    id: 338,
    length: 26 * 60 + 34,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-09-08")!,
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
    sequence: 338,
    subtitle: "Highlights & Snippets",
    title: "Modern Search",
    trailerVideo: Video(
      bytesLength: 25_800_000,
      downloadUrls: .s3(
        hd1080: "0338-trailer-1080p-bd6a8285d7bd46d9ad431c4832bc9699",
        hd720: "0338-trailer-1080p-bd6a8285d7bd46d9ad431c4832bc9699",
        sd540: "0338-trailer-1080p-bd6a8285d7bd46d9ad431c4832bc9699"
      ),
      id: "8e8c72de3a8980027a712116e11c84a0"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
