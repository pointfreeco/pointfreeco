import Foundation

extension Episode {
  public static let ep350_sqliteDataTour = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0350-sqlite-data-tour-pt4",
    exercises: _exercises,
    id: 350,
    length: 0 * 60 + 0,  // TODO
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-01-12")!,
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
    sequence: 350,
    subtitle: "CloudKit",
    title: "Tour of SQLiteData",
    trailerVideo: Video(
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "0350-trailer-1080p-67cc8faad6094d90a7ce109fd23adc83",
        hd720: "0350-trailer-1080p-67cc8faad6094d90a7ce109fd23adc83",
        sd540: "0350-trailer-1080p-67cc8faad6094d90a7ce109fd23adc83"
      ),
      id: "TODO"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
