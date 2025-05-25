import Foundation

extension Episode {
  public static let ep326_modernPersistence = Episode(
    blurb: """
      We begin building the "reminders" part of Apple's Reminders app, including listing, \
      creating, updating, and deleting them. We will also add persistent filters and sorts, per \
      list, all powered by a complex, dynamic query.
      """,
    codeSampleDirectory: "0326-modern-persistence-pt4",
    exercises: _exercises,
    id: 326,
    length: 51 * 60 + 11,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-05-26")!,
    references: [
      .init(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sharing-grdb",
        title: "SharingGRDB"
      ),
      .init(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 326,
    subtitle: "Reminders Detail, Part 1",
    title: "Modern Persistence",
    trailerVideo: .init(
      bytesLength: 49_100_000,
      downloadUrls: .s3(
        hd1080: "0326-trailer-1080p-8039687e6ecf48fd8f108a90a752bdb1",
        hd720: "0326-trailer-720p-ba5472cc2ab141ce91e0f53aa0fc5f11",
        sd540: "0326-trailer-540p-535a686d3f72480cbb7536ad6a96bbaf"
      ),
      id: "372e056336bc145317e46ad61dacb5a7"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
