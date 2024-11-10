import Foundation

extension Episode {
  public static let ep303_sqlite = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0303-sqlite-pt3",
    exercises: _exercises,
    id: 303,
    length: 36 * 60 + 13,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-11-18")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      )
    ],
    sequence: 303,
    subtitle: "SwiftUI",
    title: "SQLite",
    trailerVideo: .init(
      bytesLength: 0,
      downloadUrls: .s3(
        hd1080: "0303-trailer-1080p-TODO",
        hd720: "0303-trailer-720p-TODO",
        sd540: "0303-trailer-540p-TODO"
      ),
      vimeoId: 0
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
