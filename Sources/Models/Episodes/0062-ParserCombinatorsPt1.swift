import Foundation

extension Episode {
  static let ep62_parserCombinators_pt1 = Episode(
    blurb: """
Even though `map`, `flatMap` and `zip` pack a punch, there are still many parsing operations that can't be done using them alone. This is where "parser combinators" come into play. Let's look at a few common parsing problems and solve them using parser combinators!
""",
    codeSampleDirectory: "0062-parser-combinators-pt1",
    exercises: _exercises,
    id: 62,
    image: "https://i.vimeocdn.com/video/799122174.jpg",
    length: 19*60 + 14,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1561356000),
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
    sequence: 62,
    title: "Parser Combinators: Part 1",
    trailerVideo: .init(
      bytesLength: 48363466,
      downloadUrl: "https://player.vimeo.com/external/348470906.hd.mp4?s=5e78d99da66e48e17b5bc98e61fc8c43caa69b0a&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/348470906"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
We defined `prefix(while:)` to parse off a substring while characters matched a predicate. It can be just as useful to skip characters. Define a `drop(while:)` parser that skips characters that match a given predicate. What type of parser should `drop(while:)` return?
"""),
  Episode.Exercise(problem: """
Define a parser combinator, `zeroOrMore`, that takes a parser of `A`s as input and produces a parser of `Array<A>`s by running the existing parser as many times as it can.
"""),
  Episode.Exercise(problem: """
Define a parser combinator, `oneOrMore`, that takes a parser of `A`s as input and produces a parser of `Array<A>`s that must include at least one value.
"""),
  Episode.Exercise(problem: """
Because `oneOrMore` guarantees at least one value, let’s enforce it in the type system! Update `oneOrMore` to return `Parser<NonEmptyArray<A>>` instead of `Parser<[A]>`.
"""),
  Episode.Exercise(problem: """
Enhance the `zeroOrMore` and `oneOrMore` parsers to take a `separatedBy` argument in order to parse a comma-separated list. Ensure that only separators _between_ parsed values are consumed.
"""),
  Episode.Exercise(problem: """
Redefine the `zeroOrMoreSpaces` and `oneOrMoreSpaces` parsers in terms of `zeroOrMore` and `oneOrMore`.
"""),
]
