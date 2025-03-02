import Foundation

extension Episode {
  public static let ep314_sqlBuilding = Episode(
    blurb: """
      Last week we released SharingGRDB, an alternative to SwiftData powered by SQLite, but there \
      are a few improvements we could make. Let's take a look at some problems with the current \
      tools before giving a sneak peek at the solution: a powerful new query building library that \
      leverages many advanced Swift features that we will soon build from scratch.
      """,
    codeSampleDirectory: "0314-sql-building-pt1",
    exercises: _exercises,
    id: 314,
    length: 40 * 60 + 14,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2025-02-24")!,
    references: [
      .init(
        author: "Point-Free",
        blurb: """
          > Instantly share state among your app's features and external persistence layers, \
          including user defaults, the file system, and more.
          """,
        link: "https://github.com/pointfreeco/swift-sharing",
        title: "Sharing"
      ),
      .init(
        author: "Point-Free",
        blurb: """
          > A lightweight replacement for SwiftData and `@Query`.
          """,
        link: "https://github.com/pointfreeco/sharing-grdb",
        title: "SharingGRDB"
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
    sequence: 314,
    subtitle: "Sneak Peek, Part 1",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 83_400_000,
      downloadUrls: .s3(
        hd1080: "0314-trailer-1080p-c552c6120d4e4a7dbed052ce0466dc37",
        hd720: "0314-trailer-720p-ba68092c7bac42e6b475140160471fb3",
        sd540: "0314-trailer-540p-a6ff6bbd93984e7196d69f62fad2ca6f"
      ),
      vimeoId: 1_059_203_528
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
