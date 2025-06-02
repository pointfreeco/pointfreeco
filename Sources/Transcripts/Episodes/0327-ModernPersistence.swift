import Foundation

extension Episode {
  public static let ep327_modernPersistence = Episode(
    blurb: """
      How does our SQL-based solution for persistence compare with modern SwiftData? We put things \
      to the test by rebuilding our complex `@FetchAll` query using `@Model` and the `@Query` \
      macro!
      """,
    codeSampleDirectory: "0327-modern-persistence-pt5",
    exercises: _exercises,
    id: 327,
    length: 4571,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-02")!,
    references: [
      Reference(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sharing-grdb",
        title: "SharingGRDB"
      ),
      Reference(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 327,
    subtitle: "Reminders Detail, Part 2",
    title: "Modern Persistence",
    trailerVideo: Video(
      bytesLength: 43_700_000,
      downloadUrls: .s3(
        hd1080: "0327-trailer-1080p-1675d9fb116e4274a6aa1cb731d74a9b",
        hd720: "0327-trailer-1080p-1675d9fb116e4274a6aa1cb731d74a9b",
        sd540: "0327-trailer-1080p-1675d9fb116e4274a6aa1cb731d74a9b"
      ),
      id: "1934c1885750be16a6e7a922faebe0ca"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
