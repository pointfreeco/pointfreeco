import Foundation

extension Episode {
  public static let ep317_sqlBuilding = Episode(
    blurb: """
      We now have a type-safe syntax for generating `SELECT` statements using key paths to the
      columns we want to select, but while this syntax is nice and what many existing
      libraries use, we can do better. Let's introduce a more advanced syntax that leverages
      variadic generics and supports more complex query expressions.
      """,
    codeSampleDirectory: "0317-sql-building-pt5",
    exercises: _exercises,
    id: 317,
    length: 28 * 60 + 44,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-03-17")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      )
    ],
    sequence: 317,
    subtitle: "Advanced Selects",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 34_400_000,
      downloadUrls: .s3(
        hd1080: "0317-trailer-1080p-121f1e849a744d6b81b2352c0b1710bc",
        hd720: "0317-trailer-720p-e800785414c9487b80b0150bc7179837",
        sd540: "0317-trailer-540p-bb0b0b27c7164550978f66d098176b15"
      ),
      vimeoId: 1_063_697_836
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
