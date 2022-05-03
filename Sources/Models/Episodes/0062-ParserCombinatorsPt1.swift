import Foundation

extension Episode {
  static let ep62_parserCombinators_pt1 = Episode(
    blurb: """
      Even though `map`, `flatMap` and `zip` pack a punch, there are still many parsing operations that can't be done using them alone. This is where "parser combinators" come into play. Let's look at a few common parsing problems and solve them using parser combinators!
      """,
    codeSampleDirectory: "0062-parser-combinators-pt1",
    exercises: _exercises,
    id: 62,
    length: 19 * 60 + 14,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_561_356_000),
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
      bytesLength: 48_363_466,
      downloadUrls: .s3(
        hd1080: "0062-trailer-1080p-7d9c48a6395b45e1be6bc0959c94ba90",
        hd720: "0062-trailer-720p-2838461637914aa4a1fe9306cf9485f5",
        sd540: "0062-trailer-540p-1b4cc78e0fec4a48a6f3c5193071e157"
      ),
      vimeoId: 348_470_906
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      We defined `prefix(while:)` to parse off a substring while characters matched a predicate. It can be just as useful to skip characters. Define a `drop(while:)` parser that skips characters that match a given predicate. What type of parser should `drop(while:)` return?
      """),
  Episode.Exercise(
    problem: """
      Define a parser combinator, `zeroOrMore`, that takes a parser of `A`s as input and produces a parser of `Array<A>`s by running the existing parser as many times as it can.
      """),
  Episode.Exercise(
    problem: """
      Define a parser combinator, `oneOrMore`, that takes a parser of `A`s as input and produces a parser of `Array<A>`s that must include at least one value.
      """),
  Episode.Exercise(
    problem: """
      Because `oneOrMore` guarantees at least one value, let’s enforce it in the type system! Update `oneOrMore` to return `Parser<NonEmptyArray<A>>` instead of `Parser<[A]>`.
      """),
  Episode.Exercise(
    problem: """
      Enhance the `zeroOrMore` and `oneOrMore` parsers to take a `separatedBy` argument in order to parse a comma-separated list. Ensure that only separators _between_ parsed values are consumed.
      """),
  Episode.Exercise(
    problem: """
      Redefine the `zeroOrMoreSpaces` and `oneOrMoreSpaces` parsers in terms of `zeroOrMore` and `oneOrMore`.
      """),
]
