import Foundation

extension Episode {
  public static let ep310_sqliteSharing = Episode(
    blurb: """
      SQLite offers a lot of power and flexibility over a simple JSON file, but it also requires a \
      lot of boilerplate to get working. But we can hide away all that boilerplate using the \
      `@Shared` property wrapper and end up with something that is arguably nicer than Swift \
      Data's `@Query` macro!
      """,
    codeSampleDirectory: "0310-sqlite-sharing-pt2",
    exercises: _exercises,
    id: 310,
    length: 45 * 60 + 47,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-01-20")!,
    references: [
      .init(
        author: "Point-Free",
        blurb: """
          Instantly share state among your app's features and external persistence layers, \
          including user defaults, the file system, and more.
          """,
        link: "https://github.com/pointfreeco/swift-sharing",
        title: "Sharing"
      ),
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
    sequence: 310,
    subtitle: "The Solution",
    title: "Sharing with SQLite",
    trailerVideo: .init(
      bytesLength: 59_900_000,
      downloadUrls: .s3(
        hd1080: "0310-trailer-1080p-8cf528d79b9d46d4a642a25f02c6181a",
        hd720: "0310-trailer-720p-b40df74090f24c1a9eb5cf76d0869375",
        sd540: "0310-trailer-540p-f388b4a5dadc46ef8c8d45efa386794c"
      ),
      vimeoId: 1046210568
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
