import Foundation

extension Episode {
  static let ep60_composableParsing_flatMap = Episode(
    blurb: """
      The `map` function on parsers is powerful, but there are still a lot of things it cannot do. We will see that in trying to solve some of its limitations we are naturally led to our old friend the `flatMap` function.
      """,
    codeSampleDirectory: "0060-composable-parsing-flat-map",
    exercises: _exercises,
    id: 60,
    length: 14 * 60 + 0,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_559_541_600),
    references: [
      .combinatorsDanielSteinberg,
      .parserCombinatorsInSwift,
      .learningParserCombinatorsWithRust,
      .sparse,
      .parsec,
      .parseDontValidate,
      .ledgeMacAppParsingTechniques,
    ],
    sequence: 60,
    subtitle: "Flat‑Map",
    title: "Composable Parsing",
    trailerVideo: .init(
      bytesLength: 18_429_291,
      downloadUrls: .s3(
        hd1080: "0060-trailer-1080p-340c1654a0fd496696da34150d0a863c",
        hd720: "0060-trailer-720p-b48936cace574d8c9f058e635023337e",
        sd540: "0060-trailer-540p-2e9ed18eb45c4eb9b9ebabeaf8cc5d0f"
      ),
      vimeoId: 348_472_169
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      We have previously devoted 3 entire episodes ([part 1](/episodes/ep23-the-many-faces-of-zip-part-1), [part 2](/episodes/ep24-the-many-faces-of-zip-part-2), [part 3](/episodes/ep25-the-many-faces-of-zip-part-3)) to `zip`. In those episodes we showed that those operations are very general, and go far beyond what Swift gives us in the standard library for arrays and optionals.

      Define `zip` and `flatMap` on the `Parser` type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume _any_ of the input string if the parser fails.
      """),
  .init(
    problem: """
      Use the `zip` function defined in the previous exercise to construct a `Parser<Coordinate>` for parsing strings of the form `"40.446° N, 79.982° W"`. You may want to define `zip` overloads that work on more than 2 parsers at a time.
      """),
  // TODO: more
]
