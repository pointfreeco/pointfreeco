import Foundation

extension Episode {
  public static let ep303_sqlite = Episode(
    blurb: """
      Let’s see how to integrate a SQLite database into a SwiftUI view. We will explore the tools
      GRDB provides to query the database so that we can display its data in our UI, as well as
      build and enforce table relations to protect the integrity of our app's state. And we will
      show how everything can be exercised in Xcode previews.
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
    sequence: 303,
    subtitle: "SwiftUI",
    title: "SQLite",
    trailerVideo: .init(
      bytesLength: 32_000_000,
      downloadUrls: .s3(
        hd1080: "0303-trailer-1080p-9736a5aa80074a859fc520847401d00f",
        hd720: "0303-trailer-720p-8cfdcc3c57a94189a74e1e563099562b",
        sd540: "0303-trailer-540p-b370848117214ee2a1c87bd232db6b0c"
      ),
      id: "41e01ef87b29f49587cd6994d3ff89b8"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
