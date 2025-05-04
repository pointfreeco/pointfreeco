import Foundation

extension Episode {
  public static let ep325_modernPersistence = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0325-modern-persistence-pt3",
    exercises: _exercises,
    id: 325,
    length: 0 * 60 + 0,  // TODO
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-05-19")!,
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
    sequence: 325,
    subtitle: "Schemas",
    title: "Modern Persistence",
    trailerVideo: .init(
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "0325-trailer-1080p-TODO",
        hd720: "0325-trailer-720p-TODO",
        sd540: "0325-trailer-540p-TODO"
      ),
      vimeoId: 0  // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
