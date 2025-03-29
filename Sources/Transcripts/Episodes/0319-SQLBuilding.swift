import Foundation

extension Episode {
  public static let ep319_sqlBuilding = Episode(
    blurb: """
      We tackle one of SQL'a most important aspects in our query builder: the `WHERE` clause, \
      which filters the results of a query. And we will do so in a type-safe manner that prevents \
      us from writing nonsensical queries in Swift even when they are syntactically valid in SQL.
      """,
    codeSampleDirectory: "0319-sql-building-pt6",
    exercises: _exercises,
    id: 319,
    length: 44 * 60 + 17,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-03-31")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      )
    ],
    sequence: 319,
    subtitle: "Filtering",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 64_400_000,
      downloadUrls: .s3(
        hd1080: "0319-trailer-1080p-fdf652df841c401e88583741e4f8b014",
        hd720: "0319-trailer-720p-8f082e05efc04a188e82d305cb4caa13",
        sd540: "0319-trailer-540p-885a58e2bd3c43ba9c10c95914e0ce7e"
      ),
      vimeoId: 1069812854
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
