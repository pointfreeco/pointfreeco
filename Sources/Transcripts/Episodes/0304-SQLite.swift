import Foundation

extension Episode {
  public static let ep304_sqlite = Episode(
    blurb: """
      We conclude our introductory series on SQLite by showing how to live update SwiftUI views
      powered by database using GRDB's "value observation." Along the way we will tackle quite a few
      Swift 6 concurrency issues, and we will tie things in a bow by showing how the SwiftUI
      environment can vastly simplify how our application is powered by SQLite.
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
      .init(
        author: "Gwendal Roué",
        blurb: """
          > A toolkit for SQLite databases, with a focus on application development.
          """,
        link: "https://github.com/groue/GRDB.swift",
        title: "GRDB"
      ),
    ],
    sequence: 304,
    subtitle: "Observation",
    title: "SQLite",
    trailerVideo: .init(
      bytesLength: 40_600_000,
      downloadUrls: .s3(
        hd1080: "0304-trailer-1080p-5d27675d8035441fa0d0f8490bf9a0ca",
        hd720: "0304-trailer-720p-7be15e4ad8fe4bdeb746436ec548633f",
        sd540: "0304-trailer-540p-4b9d2859e4b3457cbb1bf1585112039f"
      ),
      vimeoId: 1_028_049_636
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
