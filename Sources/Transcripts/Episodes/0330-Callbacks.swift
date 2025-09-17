import Foundation

extension Episode {
  public static let ep330_callbacks = Episode(
    blurb: """
      We continue our series on “modern persistence” with an important topic: “callbacks.” \
      Callbacks are little hooks into the lifecycle of your data model so that you can be notified \
      or take action when something changes. We will first explore the “Active Record” pattern of \
      callbacks, popularized by Ruby on Rails, and then see how we can improve upon them.
      """,
    codeSampleDirectory: "0330-callbacks-pt1",
    exercises: _exercises,
    id: 330,
    length: 39 * 60 + 36,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2025-07-07")!,
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
    sequence: 330,
    subtitle: "Triggers",
    title: "Persistence Callbacks",
    trailerVideo: Video(
      bytesLength: 75_400_000,
      downloadUrls: .s3(
        hd1080: "0330-trailer-1080p-ffc6f5e3e48d4c119c5a50aaa39f0455",
        hd720: "0330-trailer-1080p-ffc6f5e3e48d4c119c5a50aaa39f0455",
        sd540: "0330-trailer-1080p-ffc6f5e3e48d4c119c5a50aaa39f0455"
      ),
      id: "ed135e36672e9d32273d94e3c92861f5"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
