import Foundation

extension Episode {
  public static let ep316_sqlBuilding = Episode(
    blurb: """
      We begin to build a type-safe SQL query builder from scratch by familiarizing ourselves
      with the `SELECT` statement. We will explore the SQLite documentation to understand the
      syntax, introduce a type that can generate valid statements, and write powerful inline
      snapshot tests for their output.
      """,
    codeSampleDirectory: "0316-sql-building-pt3",
    exercises: _exercises,
    id: 316,
    length: 44 * 60 + 49,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-03-10")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      )
    ],
    sequence: 316,
    subtitle: "Selects",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 59_500_000,
      downloadUrls: .s3(
        hd1080: "0316-trailer-1080p-7a3f226f91c04f4091b79bf27c07c89f",
        hd720: "0316-trailer-720p-a99340f8f70e4a5ba61f1efec629a2d8",
        sd540: "0316-trailer-540p-9b57a275bdf7418fa199b997bdc01649"
      ),
      id: "d9501d36da4d7bf205e1c70cb4c74e0d"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
