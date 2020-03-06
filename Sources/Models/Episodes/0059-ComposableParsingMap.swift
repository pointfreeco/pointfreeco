import Foundation

extension Episode {
  public static let ep59_composableParsing_map = Episode(
    blurb: """
We now have a precise, efficient definition for parsing, but we haven't even scratched the surface of its relation to functional programming. In this episode we begin to show how all of the functional operators we know and love come into play, starting with map.
""",
    codeSampleDirectory: "0059-composable-parsing-map",
    exercises: _exercises,
    id: 59,
    image: "https://i.vimeocdn.com/video/801298075.jpg",
    length: 23*60 + 12,
    permission: .subscriberOnly,
    previousEpisodeInCollection: nil,
    publishedAt: .init(timeIntervalSince1970: 1558936800),
    references: [
      .combinatorsDanielSteinberg,
      .parserCombinatorsInSwift,
      .learningParserCombinatorsWithRust,
      .sparse,
      .parsec,
      .parseDontValidate,
      .ledgeMacAppParsingTechniques,
    ],
    sequence: 59,
    title: "Composable Parsing: Map",
    trailerVideo: .init(
      bytesLength: 54937265,
      downloadUrl: "https://player.vimeo.com/external/349952515.hd.mp4?s=18f323dc2d8a15ae347893efc991c55108c27e2d&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/349952515"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Generalize the `char` parser created in this episode by turning it into a function `func char: (CharacterSet) -> Parser<Character>`. Use this parser to implement the `northSouth` and `eastWest` parsers without needing to use `flatMap`.
"""),
  .init(problem: """
We have previously devoted 3 entire episodes ([part 1](/episodes/ep23-the-many-faces-of-zip-part-1), [part 2](/episodes/ep24-the-many-faces-of-zip-part-2), [part 3](/episodes/ep25-the-many-faces-of-zip-part-3)) to `zip`, and _then_ 5 (!) entire episodes ([part 1](/episodes/ep42-the-many-faces-of-flat-map-part-1), [part 2](/episodes/ep43-the-many-faces-of-flat-map-part-2), [part 3](/episodes/ep44-the-many-faces-of-flat-map-part-3), [part 4](/episodes/ep45-the-many-faces-of-flat-map-part-4), [part 5](/episodes/ep46-the-many-faces-of-flat-map-part-5)) to `flatMap`. In those episodes we showed that those operations are very general, and go far beyond what Swift gives us in the standard library for arrays and optionals.

Define `zip` and `flatMap` on the `Parser` type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume _any_ of the input string if the parser fails.
"""),
  .init(problem: """
Use the `flatMap` defined in the previous exercise to implement the `northSouth` and `eastWest` parsers. You will need to use the `always` and `never` parsers in their implementations.
"""),
  .init(problem: """
Using only `map` and `flatMap`, construct a parser for parsing a `Coordinate` value from the string `"40.446° N, 79.982° W"`.

While it's possible to solve this exercise, it isn't particularly nice. What went wrong, and what other operation could you use to make it simpler?
""")
]
