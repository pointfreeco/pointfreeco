import Foundation

extension Episode {
  public static let ep130_parsingPerformance = Episode(
    blurb: """
It is well accepted that hand-rolled, imperative parsers are vastly more performant than parsers built with combinators. However, we show that by employing all of our performance tricks we can get within a stone's throw of the performance of imperative parsers, and with much more maintainable code.
""",
    codeSampleDirectory: "0130-parsing-performance-pt3",
    exercises: _exercises,
    id: 130,
    image: "https://i.vimeocdn.com/video/1019899482.jpg",
    length: 58*60 + 46,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1608530400),
    references: [
      .init(
        author: "Chris Eidhof & Florian Kugler",
        blurb: """
          This [Swift Talk](https://talk.objc.io) episode was the inspiration for two of the CSV parsers we built in this episode, and formed the basis of how we could compare combinator-style parsing with imperative-style parsing.

          > We show a parsing technique that we use for many parsing tasks in our day-to-day work.
          """,
        link: "https://talk.objc.io/episodes/S01E170-parsing-with-mutating-methods",
        publishedAt: referenceDateFormatter.date(from: "2019-09-20"),
        title: "Parsing with Mutating Methods"
      ),
      .swiftBenchmark,
      .utf8(),
      .stringsInSwift4(),
    ],
    sequence: 130,
    subtitle: "The Point",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 64504653,
      vimeoId: 492807428,
      vimeoSecret: "56158dafe0996029229c7722923089aba104a227"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
