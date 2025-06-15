import Foundation

extension Episode {
  public static let ep328_modernPersistence = Episode(
    blurb: """
      We conclude our series on “modern persistence” with advanced queries that leverage reusable \
      SQL builders, “safe” SQL strings, and complex aggregations, including JSON arrays and a \
      query that selects many stats in a single query.
      """,
    codeSampleDirectory: "0328-modern-persistence-pt6",
    exercises: _exercises,
    id: 328,
    length: 53 * 60 + 35,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-16")!,
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
    sequence: 328,
    subtitle: "Advanced Aggregations",
    title: "Modern Persistence",
    trailerVideo: Video(
      bytesLength: 46_100_000,
      downloadUrls: .s3(
        hd1080: "0328-trailer-1080p-5eb8bc8a572742ddbdf06072dde404db",
        hd720: "0328-trailer-1080p-5eb8bc8a572742ddbdf06072dde404db",
        sd540: "0328-trailer-1080p-5eb8bc8a572742ddbdf06072dde404db"
      ),
      id: "84c4428623ab97d557f7f2e245b15b3d"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
