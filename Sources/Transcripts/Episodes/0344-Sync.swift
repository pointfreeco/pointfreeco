import Foundation

extension Episode {
  public static let ep344_sync = Episode(
    blurb: """
      We want SQLiteData to work seamlessly behind the scenes without you having to worry about \
      how it works, but we also wanted to make sure you had full access to everything happening \
      under the hood. Let’s explore the secret sync metadata table to see how we can fetch and \
      even join against data related to sync, including sharing information and more.
      """,
    codeSampleDirectory: "0344-sync-pt5",
    exercises: _exercises,
    id: 344,
    length: 42 * 60 + 41,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-11-03")!,
    references: [
      Reference(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sqlite-data",
        title: "SQLiteData"
      ),
      Reference(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 344,
    subtitle: "Sync Metadata",
    title: "CloudKit Sync",
    trailerVideo: Video(
      bytesLength: 73_500_000,
      downloadUrls: .s3(
        hd1080: "0344-trailer-1080p-317f99b41b5949b7ad8880f26d6bbf4a",
        hd720: "0344-trailer-1080p-317f99b41b5949b7ad8880f26d6bbf4a",
        sd540: "0344-trailer-1080p-317f99b41b5949b7ad8880f26d6bbf4a"
      ),
      id: "e72b1a9faf04f815a9685ce01ba1bbc9"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
