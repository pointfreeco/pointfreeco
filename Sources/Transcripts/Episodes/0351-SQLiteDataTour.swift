import Foundation

extension Episode {
  public static let ep351_sqliteDataTour = Episode(
    blurb: """
      We've extended the tour with a few bonus episodes that show how SQLiteData integrates with \
      Xcode previews and tests! No need to painstakingly mock your persistence layer: previews \
      actually hit the database, and the library automatically supplies a mock CloudKit sync \
      engine so you can easily preview how iCloud sharing looks in your UI.
      """,
    codeSampleDirectory: "0351-sqlite-data-tour-pt5",
    exercises: _exercises,
    id: 351,
    length: 38 * 19 + 20,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-01-19")!,
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
    sequence: 351,
    subtitle: "Previews",
    title: "Tour of SQLiteData",
    trailerVideo: Video(
      bytesLength: 54_700_000,
      downloadUrls: .s3(
        hd1080: "0351-trailer-1080p-78af0a5bc3254133b5fc4592b93ae636",
        hd720: "0351-trailer-1080p-78af0a5bc3254133b5fc4592b93ae636",
        sd540: "0351-trailer-1080p-78af0a5bc3254133b5fc4592b93ae636"
      ),
      id: "5ae976301710c1049ab6b237a6a61718"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
