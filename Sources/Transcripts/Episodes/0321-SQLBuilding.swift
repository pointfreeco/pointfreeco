import Foundation

extension Episode {
  public static let ep321_sqlBuilding = Episode(
    blurb: """
      It’s time to support one of the most complicated parts of SQL in our query building library: \
      joins. We will design an API that is simple to use but leverages some seriously advanced \
      language features, including type-level parameter packs.
      """,
    codeSampleDirectory: "0321-sql-building-pt8",
    exercises: _exercises,
    id: 321,
    length: 28 * 60 + 37,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-04-14")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      )
    ],
    sequence: 321,
    subtitle: "Joins in Swift",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 52_400_000,
      downloadUrls: .s3(
        hd1080: "0321-trailer-1080p-81a0acd5f57c42dead93bf21cd477071",
        hd720: "0321-trailer-720p-18bd9d10a291412e8cb9d58244720b94",
        sd540: "0321-trailer-540p-2dfa37dd1f694d4abf8548d5a39922a6"
      ),
      vimeoId: 1_072_988_440
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
