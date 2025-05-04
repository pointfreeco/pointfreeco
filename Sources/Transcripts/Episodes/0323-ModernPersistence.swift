import Foundation

extension Episode {
  public static let ep323_modernPersistence = Episode(
    blurb: """
      What are the best, modern practices for persisting your application's state? We explore the \
      topic by rebuilding Apple's Reminders app from scratch using SQLite, the most widely \
      deployed database in all software. We will start by designing the schema that models our \
      domain.
      """,
    codeSampleDirectory: "0323-modern-persistence-pt1",
    exercises: _exercises,
    id: 323,
    length: 57 * 60 + 10,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-05-05")!,
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
    sequence: 323,
    subtitle: "Schemas",
    title: "Modern Persistence",
    trailerVideo: .init(
      bytesLength: 178_600,
      downloadUrls: .s3(
        hd1080: "0323-trailer-1080p-b2f8b89d756f4b94a8c3995d8c65ecac",
        hd720: "0323-trailer-720p-da8f8dd1e01b409daadb862206122f4c",
        sd540: "0323-trailer-540p-46d5b44c93be4bc7bea8f918bed8b320"
      ),
      vimeoId: 1080931366
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
