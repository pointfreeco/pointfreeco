import Foundation

extension Episode {
  public static let ep127_parsingPerformance = Episode(
    blurb: """
Let’s take a quick deep dive into the topic of Swift strings. Swift represents strings in many ways, each with its own behavior and performance characteristics. We will benchmark them in order to better understand how we can improve the performance of the parsers we write.
""",
    codeSampleDirectory: "0127-parsing-performance-pt1",
    exercises: _exercises,
    id: 127,
    image: "TODO",
    length: 35*60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1606716000),
    references: [
      // TODO
    ],
    sequence: 127,
    subtitle: "Part 1", // TODO: or something specific, like "String Representations"?
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 0,
      vimeoId: 0,
      vimeoSecret: ""
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
