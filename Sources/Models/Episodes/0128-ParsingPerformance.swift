import Foundation

extension Episode {
  public static let ep128_parsingPerformance = Episode(
    blurb: """
Now that we're comfortable with the performance characteristics of Swift strings and their abstraction levels, let's apply this knowledge to the parser type. We will convert parsers of several complexities to work on lower-level abstractions to understand the trade-offs and explore how to decide which abstraction we should be working in.
""",
    codeSampleDirectory: "0128-parsing-performance-pt2",
    exercises: _exercises,
    id: 128,
    image: "TODO",
    length: 0, // TODO
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1607320800),
    references: [
      .swiftBenchmark
    ],
    sequence: 128,
    subtitle: "Combinators",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 0, // TODO
      vimeoId: 0, // TODO
      vimeoSecret: "TODO"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
