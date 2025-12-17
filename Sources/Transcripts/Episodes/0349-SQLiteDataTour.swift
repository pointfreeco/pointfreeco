import Foundation

extension Episode {
  public static let ep349_sqliteDataTour = Episode(
    blurb: """
      We explore how SQLiteData gives you precise control over your data model, including larger \
      blobs of data, by adding a photo avatar feature to our scorekeeping app. Along the way we \
      will explore a new iOS 26 style confirmation dialogs and a SwiftUI binding trick.
      """,
    codeSampleDirectory: "0349-sqlite-data-tour-pt3",
    exercises: _exercises,
    id: 349,
    length: 31 * 60 + 14,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-01-05")!,
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
    sequence: 349,
    subtitle: "Assets",
    title: "Tour of SQLiteData",
    trailerVideo: Video(
      bytesLength: 25_500_000,
      downloadUrls: .s3(
        hd1080: "0349-trailer-1080p-72765bcf64f3452bbb24f0b737b86df4",
        hd720: "0349-trailer-1080p-72765bcf64f3452bbb24f0b737b86df4",
        sd540: "0349-trailer-1080p-72765bcf64f3452bbb24f0b737b86df4"
      ),
      id: "ab39b0b2f5ed7c8e9299e30c9a835119"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
