import Foundation

extension Episode {
  public static let ep324_modernPersistence = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0324-modern-persistence-pt2",
    exercises: _exercises,
    id: 324,
    length: 0 * 60 + 0,  // TODO
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-05-12")!,
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
    sequence: 324,
    subtitle: "Schemas",
    title: "Modern Persistence",
    trailerVideo: .init(
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "0324-trailer-1080p-TODO",
        hd720: "0324-trailer-720p-TODO",
        sd540: "0324-trailer-540p-TODO"
      ),
      vimeoId: 0  // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
