import Foundation

extension Episode {
  public static let ep346_sync = Episode(
    blurb: """
      We round out are synchronization series with a grab bag finale. We'll explore explicit \
      synchronization, custom logout behavior, how the library handles read-only permissions, and \
      how you can incorporate theses permissions in your app's behavior.
      """,
    codeSampleDirectory: "0346-sync-pt6",
    exercises: _exercises,
    id: 346,
    length: 56 * 60 + 19,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-11-17")!,
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
    sequence: 346,
    subtitle: "Finesse",
    title: "CloudKit Sync",
    trailerVideo: Video(
      bytesLength: 32_200_000,
      downloadUrls: .s3(
        hd1080: "0346-trailer-1080p-5a69ea00be1845cd9b8bf47c892383f6",
        hd720: "0346-trailer-1080p-5a69ea00be1845cd9b8bf47c892383f6",
        sd540: "0346-trailer-1080p-5a69ea00be1845cd9b8bf47c892383f6"
      ),
      id: "6aeede0f6944626cf232f2f1006cd6e2"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
