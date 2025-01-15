import Foundation

extension Episode {
  public static let ep311_sqliteSharing = Episode(
    blurb: """
      Let's leverage our new `@Shared` SQLite strategy by adding a brand new feature: archiving. \
      We will see how easy it is to incorporate queries directly into a SwiftUI view, and we will \
      expand our tools to support even more kinds of queries.
      """,
    codeSampleDirectory: "0311-sqlite-sharing-pt3",
    exercises: _exercises,
    id: 311,
    length: 27 * 60 + 55,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-01-27")!,
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
    sequence: 311,
    subtitle: "Advanced Queries",
    title: "Sharing with SQLite",
    trailerVideo: .init(
      bytesLength: 57_500_000,
      downloadUrls: .s3(
        hd1080: "0311-trailer-1080p-c86dd76042714245bf942695a3a93acf",
        hd720: "0311-trailer-720p-c83ced76d77d46e090b2f41ff74b8b08",
        sd540: "0311-trailer-540p-43423f87bc5f4a3cba6759aa5ac0eac4"
      ),
      vimeoId: 1_046_468_864
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
