import Foundation

extension Episode {
  public static let ep347_sqliteDataTour = Episode(
    blurb: """
      We give a tour of our SQLiteData library, a fast and lightweight alternative to SwiftData.
      We'll set up a fresh project with the package, define models and configure the database, and
      even write SQL migrations with the help of Xcode's Coding Assistant.
      """,
    codeSampleDirectory: "0347-sqlite-data-tour-pt1",
    exercises: _exercises,
    id: 347,
    length: 28 * 60 + 56,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2025-12-08")!,
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
    sequence: 347,
    subtitle: "Basics",
    title: "Tour of SQLiteData",
    trailerVideo: Video(
      bytesLength: 58_100_000,
      downloadUrls: .s3(
        hd1080: "0347-trailer-1080p-2d94883fa9364d35afe3c59d7a46719e",
        hd720: "0347-trailer-1080p-2d94883fa9364d35afe3c59d7a46719e",
        sd540: "0347-trailer-1080p-2d94883fa9364d35afe3c59d7a46719e"
      ),
      id: "6274077ff84ff4f09d2ce71df5f69749"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
