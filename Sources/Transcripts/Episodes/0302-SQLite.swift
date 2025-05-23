import Foundation

extension Episode {
  public static let ep302_sqlite = Episode(
    blurb: """
      Interfacing with SQLite's C library from Swift is possible, but clunky. Luckily there are
      friendlier, "Swiftier" interfaces the community has built, so let's take a look at the most
      popular: GRDB. We'll explore how it can help us avoid pitfalls and boilerplate required to use
      the C library, and how its typed SQL helpers can even help us avoid runtime issues at compile
      time.
      """,
    codeSampleDirectory: "0302-sqlite-pt2",
    exercises: _exercises,
    id: 302,
    length: 35 * 60 + 23,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-11-11")!,
    references: [
      .init(
        author: "Gwendal Roué",
        blurb: """
          > A toolkit for SQLite databases, with a focus on application development.
          """,
        link: "https://github.com/groue/GRDB.swift",
        title: "GRDB"
      ),
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      ),
    ],
    sequence: 302,
    subtitle: "GRDB",
    title: "SQLite",
    trailerVideo: .init(
      bytesLength: 48_500_000,
      downloadUrls: .s3(
        hd1080: "0302-trailer-1080p-bac7199991a74e5cbff8cfe451a89c0b",
        hd720: "0302-trailer-720p-797fc00baeac40e58e874f9502bd12fd",
        sd540: "0302-trailer-540p-5d2bf3546d46460c901fee3b4a3c4a1d"
      ),
      id: "073eeb2319e453f58cf42f1efe98e208"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
