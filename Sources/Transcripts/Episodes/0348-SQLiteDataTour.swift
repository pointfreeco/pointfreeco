import Foundation

extension Episode {
  public static let ep348_sqliteDataTour = Episode(
    blurb: """
      We add another feature to our SQLiteData-based app to show how the tools interact with \
      observable models and SwiftUI view lifecycles. We'll show how the library gives you ultimate \
      control over the precision and performance of how data is fetched and loaded in your app.
      """,
    codeSampleDirectory: "0348-sqlite-data-tour-pt2",
    exercises: _exercises,
    id: 348,
    length: 42 * 60 + 34,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2025-12-15")!,
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
    sequence: 348,
    subtitle: "Querying",
    title: "Tour of SQLiteData",
    trailerVideo: Video(
      bytesLength: 34_500_000,
      downloadUrls: .s3(
        hd1080: "0348-trailer-1080p-dea4e317a8804df9897e7810940e43b0",
        hd720: "0348-trailer-1080p-dea4e317a8804df9897e7810940e43b0",
        sd540: "0348-trailer-1080p-dea4e317a8804df9897e7810940e43b0"
      ),
      id: "a74467c8c2033b4c347aa5953b8ef70a"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
