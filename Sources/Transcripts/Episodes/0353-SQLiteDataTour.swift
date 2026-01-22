import Foundation

extension Episode {
  public static let ep353_sqliteDataTour = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0353-sqlite-data-tour-pt6",
    exercises: _exercises,
    id: 353,
    length: 20 * 60 + 52,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-02-02")!,
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
    sequence: 353,
    subtitle: "Advanced Testing",
    title: "Tour of SQLiteData",
    trailerVideo: Video(
      bytesLength: 24_400_000,
      downloadUrls: .s3(
        hd1080: "0353-trailer-1080p-027a2982e1534e27ad0c2881ffe14a47",
        hd720: "0353-trailer-1080p-027a2982e1534e27ad0c2881ffe14a47",
        sd540: "0353-trailer-1080p-027a2982e1534e27ad0c2881ffe14a47"
      ),
      id: "6b2acda09f94242ddbdd7fea8fe674b1"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
