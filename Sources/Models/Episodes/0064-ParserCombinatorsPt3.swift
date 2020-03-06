import Foundation

extension Episode {
  public static let ep64_parserCombinators_pt3 = Episode(
    blurb: """
Now that we've looked at how to parse multiple values given a single parser, let's try to parse a single value using multiple parsers! And after defining a bunch of these parser combinators we'll finally be able to ask: "what's the point!?"
""",
    codeSampleDirectory: "0064-parser-combinators-pt3",
    exercises: _exercises,
    id: 64,
    image: "https://i.vimeocdn.com/video/799115426.jpg",
    length: 19*60 + 47,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 63,
    publishedAt: .init(timeIntervalSince1970: 1562565600),
    references: [
      .combinatorsDanielSteinberg,
      .parserCombinatorsInSwift,
      .regexpParser,
      .regexesVsCombinatorialParsing,
      .learningParserCombinatorsWithRust,
      .sparse,
      .parsec,
      .parseDontValidate,
      .ledgeMacAppParsingTechniques,
    ],
    sequence: 64,
    title: "Parser Combinators: Part 3",
    trailerVideo: .init(
      bytesLength: 15830908,
      downloadUrl: "https://player.vimeo.com/external/348470834.hd.mp4?s=185ff244ef456500852a219970c1a82c73df09d2&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/348470834"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Many higher-order functions on `Array` are also useful to define on `Parser` as parser combinators. As an example, define a `compactMap` with the following signature: `((A) -> B?) -> (Parser<A>) -> Parser<B>`.
"""),
  Episode.Exercise(problem: """
Define a `filter` parser combinator with the following signature: `((A) -> Bool) -> (Parser<A>) -> Parser<B>`.
"""),
  Episode.Exercise(problem: """
Define `filter` in terms of `compactMap`.
"""),
  Episode.Exercise(problem: """
Define an `either` parser combinator with the following signature: `((A) -> Either<B, C>) -> (Parser<A>) -> Parser<Either<B, C>>`.
"""),
  Episode.Exercise(problem: """
Redefine the `double` parser using parser combinators like `oneOf` to be more resilient than the one we've currently defined. It should handle positive and negative numbers and ignore trailing decimals. _I.e._ it should parse `"1"` as `1.0`, `"-42"` as `-42.0`, `"+50"` as `50.0`, and "-123.456.789" as `-123.456` without consuming `".789"`.
"""),
]
