import Foundation

extension Episode {
  public static let ep312_sqliteSharing = Episode(
    blurb: """
      We are now driving several features using SQLite using a simple property wrapper that offers \
      the same ergonomics as Swift Data's `@Query` macro, and automatically keeps the view in sync \
      with the database. Let's add one more feature to leverage _dynamic_ queries by allowing the \
      user to change how the data is sorted.
      """,
    codeSampleDirectory: "0312-sqlite-sharing-pt4",
    exercises: _exercises,
    id: 312,
    length: 39 * 60 + 3,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-02-03")!,
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
    sequence: 312,
    subtitle: "Dynamic Queries",
    title: "Sharing with SQLite",
    trailerVideo: .init(
      bytesLength: 53_000_000,
      downloadUrls: .s3(
        hd1080: "0312-trailer-1080p-8cab69766ff945feb07593f84ddb91e3",
        hd720: "0312-trailer-720p-cde825921cec44ed875c5193b83d72d0",
        sd540: "0312-trailer-540p-ec212a1ec8154857864b7141431c54b7"
      ),
      vimeoId: 1_046_539_325
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
