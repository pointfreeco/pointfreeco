import Foundation

extension Episode {
  public static let ep320_sqlBuilding = Episode(
    blurb: """
      We dive into the "relational" part of relational databases by learning how tables can
      reference one another, the various ways queries can join these relations together, and even
      how to aggregate nuanced data across these relations, all without ever hopping over to Xcode.
      """,
    codeSampleDirectory: "0320-sql-building-pt7",
    exercises: _exercises,
    id: 320,
    length: 49 * 60 + 21,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-04-07")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      )
    ],
    sequence: 320,
    subtitle: "Joins",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 98_900_000,
      downloadUrls: .s3(
        hd1080: "0320-trailer-1080p-d09a305485834044be4a98bd03498db6",
        hd720: "0320-trailer-720p-6b38c02f927844d1a7f2b31eb34d6f87",
        sd540: "0320-trailer-540p-55883027eac042d18cede9948344e327"
      ),
      vimeoId: 1_072_600_139
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
