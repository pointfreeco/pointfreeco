import Foundation

extension Episode {
  public static let ep350_sqliteDataTour = Episode(
    blurb: """
      We conclude our tour by adding iCloud synchronization _and_ collaborative sharing, all in
      under thirty minutes! We will show how support will not require any fundamental changes to our
      application, show off live synchronization across multiple devices and users, and we will use
      our upcoming "Point-Free Way" skill documents to let Xcode's Coding Assistant write things for
      us.
      """,
    codeSampleDirectory: "0350-sqlite-data-tour-pt4",
    exercises: _exercises,
    id: 350,
    length: 27 * 60 + 20,
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
      bytesLength: 26_100_000,
      downloadUrls: .s3(
        hd1080: "0350-trailer-1080p-fc4278b937df4c129864b2281c5c4ba5",
        hd720: "0350-trailer-1080p-fc4278b937df4c129864b2281c5c4ba5",
        sd540: "0350-trailer-1080p-fc4278b937df4c129864b2281c5c4ba5"
      ),
      id: "ac389f5f41fdd51dcd8a0d1c8f139e68"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
