import Foundation

extension Episode {
  public static let ep130_parsingPerformance = Episode(
    blurb: """
It is well accepted that hand-rolled, imperative parsers are vastly more performant than parsers built with combinators. However, we show that by employing all of our performance tricks we can get within a stone's throw of the performance of imperative parsers, and with much more maintainable code.
""",
    codeSampleDirectory: "0130-parsing-performance-pt3",
    exercises: _exercises,
    id: 130,
    image: "TODO",
    length: 58*60 + 46,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1608530400),
    references: [
      .swiftBenchmark
    ],
    sequence: 130,
    subtitle: "The Point",
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
