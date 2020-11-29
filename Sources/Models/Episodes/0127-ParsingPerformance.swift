import Foundation

extension Episode {
  public static let ep127_parsingPerformance = Episode(
    blurb: """
We want to explore the performance of composable parsers, but to do so we must first take a deep dive into the Swift string API. There are multiple abstractions of strings in Swift, each with its own benefits and performance characteristics. We will benchmark them in order to get a scientific basis for comparison, and will describe how to properly write a benchmark.
""",
    codeSampleDirectory: "0127-parsing-performance-pt1",
    exercises: _exercises,
    id: 127,
    image: "https://i.vimeocdn.com/video/1004853903.jpg",
    length: 35*60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1606716000),
    references: [
      .swiftBenchmark
    ],
    sequence: 127,
    subtitle: "Strings",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 59207692,
      vimeoId: 485209021,
      vimeoSecret: "5e4fb1ff00a978976ecdf2873ae3b59d454c68d4"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
