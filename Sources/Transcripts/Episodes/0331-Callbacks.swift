import Foundation

extension Episode {
  public static let ep331_callbacks = Episode(
    blurb: """
      We build a bunch of triggers in a schema-safe, type-safe way using APIs from the \
      StructuredQueries library, including a callback that ensures the Reminders app always has at \
      least one list, and a callback that helps us support drag–drop positional ordering of lists.
      """,
    codeSampleDirectory: "0331-callbacks-pt2",
    exercises: _exercises,
    id: 331,
    length: 28 * 60 + 33,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-07-14")!,
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
    sequence: 331,
    subtitle: "Type-Safe Triggers",
    title: "Persistence Callbacks",
    trailerVideo: Video(
      bytesLength: 57_300_000,
      downloadUrls: .s3(
        hd1080: "0331-trailer-1080p-541f2af5e87e47cc9e96498bf02ca7e9",
        hd720: "0331-trailer-1080p-541f2af5e87e47cc9e96498bf02ca7e9",
        sd540: "0331-trailer-1080p-541f2af5e87e47cc9e96498bf02ca7e9"
      ),
      id: "e3edd75dfecddb1f563a792af0093646"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
