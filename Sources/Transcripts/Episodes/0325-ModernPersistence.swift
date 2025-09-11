import Foundation

extension Episode {
  public static let ep325_modernPersistence = Episode(
    blurb: """
      We flesh out the reminders lists feature using advanced queries that aggregate reminders \
      counts and bundle results up into a custom type _via_ the `@Selection` macro. And we show \
      how "drafts"—a unique feature of StructuredQueries—allow us to create and update values \
      using the same view, all without sacrificing the preciseness of our domain model.
      """,
    codeSampleDirectory: "0325-modern-persistence-pt3",
    exercises: _exercises,
    id: 325,
    length: 46 * 60 + 56,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-05-19")!,
    references: [
      .init(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sqlite-data",
        title: "SQLiteData"
      ),
      .init(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 325,
    subtitle: "Reminders Lists, Part 2",
    title: "Modern Persistence",
    trailerVideo: .init(
      bytesLength: 62_500_000,
      downloadUrls: .s3(
        hd1080: "0325-trailer-1080p-64dfe445b69e4045bf3060cc9bab888b",
        hd720: "0325-trailer-720p-fb85f7a2288e4727966f142b6b55e75c",
        sd540: "0325-trailer-540p-eda2db6b85874e6fa7b6ce4b0555d776"
      ),
      id: "a4febd878204e9cf2563445c5beaf22c"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
