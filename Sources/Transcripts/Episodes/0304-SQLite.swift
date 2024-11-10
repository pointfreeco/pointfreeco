import Foundation

extension Episode {
  public static let ep304_sqlite = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0304-sqlite-pt4",
    exercises: _exercises,
    id: 304,
    length: 36 * 60 + 13,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-11-25")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      ),
    ],
    sequence: 304,
    subtitle: "SwiftUI",
    title: "SQLite",
    trailerVideo: .init(
      bytesLength: 0,
      downloadUrls: .s3(
        hd1080: "0304-trailer-1080p-TODO",
        hd720: "0304-trailer-720p-TODO",
        sd540: "0304-trailer-540p-TODO"
      ),
      vimeoId: 0
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
