import Foundation

extension Episode {
  public static let ep313_pfLive_SharingGRDB = Episode(
    blurb: """
      We celebrate 7 years with a live stream! We discuss some recent updates around our popular [Sharing](http://github.com/pointfreeco/swift-sharing) library; open source [SharingGRDB](http://github.com/pointfreeco/sqlite-data) live, which is a new lightweight alternative to SwiftData that is powered by Sharing and [GRDB](http://github.com/groue/GRDB.swift); and we give a sneak peek of an upcoming series and library.
      """,
    codeSampleDirectory: "0313-pf-live-grdb-sharing",
    exercises: _exercises,
    id: 313,
    length: 123 * 60 + 53,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2025-02-17")!,
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
        link: "https://github.com/pointfreeco/sqlite-data",
        title: "Sharing"
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
    sequence: 313,
    subtitle: "SQLiteData",
    title: "Point-Free Live",
    trailerVideo: .init(
      bytesLength: 16_100_000,
      downloadUrls: .s3(
        hd1080: "0313-trailer-1080p-cc0f90908bac44f6b17d330adeaf6830",
        hd720: "0313-trailer-720p-e4bdc1a8729646a2b316264bd7645fbe",
        sd540: "0313-trailer-540p-57dd7ce910bb4dc9827d8be75ba9f2cc"
      ),
      id: "517294ce32678939937015d17f94d8d8"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
