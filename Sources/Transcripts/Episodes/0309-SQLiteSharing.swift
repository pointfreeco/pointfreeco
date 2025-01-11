import Foundation

extension Episode {
  public static let ep309_sqliteSharing = Episode(
    blurb: """
      Persisting app state to user defaults or a JSON file is simple and convenient, but it starts \
      to break down when you need to present this data in more complex ways, and this is where \
      SQLite really shines. Let's get a handle on the problem with some state that is currently \
      persisted to a JSON file, and let's see how SQLite fixes it.
      """,
    codeSampleDirectory: "0309-sqlite-sharing-pt1",
    exercises: _exercises,
    id: 309,
    length: 45 * 60 + 59,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-01-13")!,
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
    sequence: 309,
    subtitle: "The Problems",
    title: "Sharing with SQLite",
    trailerVideo: .init(
      bytesLength: 59_800_000,
      downloadUrls: .s3(
        hd1080: "0309-trailer-1080p-3249e21fe426490693e4c1ddec367ded",
        hd720: "0309-trailer-720p-ca4e6908ce684da591a84bac156d40fd",
        sd540: "0309-trailer-540p-82631668efe846e3b25903738c2c829f"
      ),
      vimeoId: 1_045_868_189
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
