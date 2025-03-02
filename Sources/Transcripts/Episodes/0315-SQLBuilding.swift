import Foundation

extension Episode {
  public static let ep315_sqlBuilding = Episode(
    blurb: """
      We finish a sneak peek of our upcoming Structured Queries library by showing how queries built
      with the library can be reused and composed together, and how we can replace all of the
      raw queries in our application with simpler, safer query builders.
      """,
    codeSampleDirectory: "0315-sql-building-pt2",
    exercises: _exercises,
    id: 315,
    length: 42 * 60 + 47,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2025-03-03")!,
    references: [
      .init(
        author: "Amritpan Kaur & Pavel Yaskevich",
        blurb: """
          > Key path expressions access properties dynamically. They are declared with a concrete
          > root type and one or more key path components that define a path to a resulting value
          > via the type’s properties, subscripts, optional-chaining expressions, forced unwrapped
          > expressions, or self. This proposal expands key path expression access to include static
          > properties of a type, i.e., metatype keypaths.
          """,
        link:
          "https://github.com/swiftlang/swift-evolution/blob/main/proposals/0438-metatype-keypath.md",
        title: "Metatype Keypaths"
      ),
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
    sequence: 315,
    subtitle: "Sneak Peek, Part 2",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 41_200_000,
      downloadUrls: .s3(
        hd1080: "0315-trailer-1080p-8083caf55f66416ba30fea855e183616",
        hd720: "0315-trailer-720p-1fa7fb0525ea46829e04c3b62276b3bb",
        sd540: "0315-trailer-540p-05da8a5e93b74faf9faf6944a28a75a1"
      ),
      vimeoId: 1_060_278_072
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
