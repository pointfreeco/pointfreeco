import Foundation

extension Episode {
  public static let ep352_sqliteDataTour = Episode(
    blurb: """
      SQLiteData is incredibly test-friendly. We will show how to configure a test suite for \
      your data layer, how to seed the database for testing, how to assert against this data as it \
      changes, how to employ `expectNoDifference` for better debugging over Swift Testing's \
      `#expect` macro, and how to control the `uuid()` function used by SQLite.
      """,
    codeSampleDirectory: "0352-sqlite-data-tour-pt6",
    exercises: _exercises,
    id: 352,
    length: 30 * 60 + 15,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-01-26")!,
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
    sequence: 352,
    subtitle: "Testing",
    title: "Tour of SQLiteData",
    trailerVideo: Video(
      bytesLength: 42_900_000,
      downloadUrls: .s3(
        hd1080: "0352-trailer-1080p-daefbb37d9cc42d799af3c7bd2bc1287",
        hd720: "0352-trailer-1080p-daefbb37d9cc42d799af3c7bd2bc1287",
        sd540: "0352-trailer-1080p-daefbb37d9cc42d799af3c7bd2bc1287"
      ),
      id: "b25b2ca9b7d370359f02d94696fa62c6"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
