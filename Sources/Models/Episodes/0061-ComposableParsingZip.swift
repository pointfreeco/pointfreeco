import Foundation

extension Episode {
  static let ep61_composableParsing_zip = Episode(
    blurb: """
While `flatMap` allowed us to take our parser type to the next level, it introduced a nesting problem. Isn't `flatMap` all about solving nesting problems!? Well, we have one more operation at our disposal: `zip`! Let's define `zip` on the parser type, see what it brings to the table, and finally ask, "what's the point?"
""",
    codeSampleDirectory: "0061-composable-parsing-zip",
    exercises: _exercises,
    id: 61,
    length: 27 * 60 + 22,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1560146400),
    references: [
      .combinatorsDanielSteinberg,
      .parserCombinatorsInSwift,
      .learningParserCombinatorsWithRust,
      .sparse,
      .parsec,
      .parseDontValidate,
      .ledgeMacAppParsingTechniques,
    ],
    sequence: 61,
    subtitle: "Zip",
    title: "Composable Parsing",
    trailerVideo: .init(
      bytesLength: 43072387,
      downloadUrls: .s3(
        hd1080: "0061-trailer-1080p-f02c926be33a4e5e8fc2d2dd7b7443b8",
        hd720: "0061-trailer-720p-d37c409b28c44751ac8554eaf51d6045",
        sd540: "0061-trailer-540p-41549ab898624e6597ae3f62cfa3b7b4"
      ),
      vimeoId: 349951712
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Define an alternate parser that parses coordinates formatted as [decimal degree](https://en.wikipedia.org/wiki/Decimal_degrees) minutes, like `"40° 26.767′ N 79° 58.933′ W"`.
"""),
  Episode.Exercise(problem: """
Define an alternate parser that parses coordinates formatted as [decimal degree](https://en.wikipedia.org/wiki/Decimal_degrees) minutes _and_ seconds, like `"40° 26′ 46″ N 79° 58′ 56″ W"`.
"""),
  Episode.Exercise(problem: """
Build an [ISO-8601](https://en.wikipedia.org/wiki/ISO_8601) parser that can parse the date string `2018-01-29T12:34:56Z`.
"""),
  Episode.Exercise(problem: """
Create a parser, `oneOrMoreSpaces`, that parses one or more spaces off the beginning of a string. Why can't this parser be defined using `map`, `flatMap`, and/or `zip`?
"""),
  Episode.Exercise(problem: """
Create a parser, `zeroOrMoreSpaces`, that parses _zero_ or more spaces off the beginning of a string. How does it differ from `oneOrMoreSpaces`?
"""),
  Episode.Exercise(problem: """
Define a function that shares the common parsing logic of `oneOrMoreSpaces` and `zeroOrMoreSpaces`. It should have the signature `((Character) -> Bool) -> Parser<Substring>`. Redefine `oneOrMoreSpaces` and `zeroOrMoreSpaces` in terms of this function.
"""),
  Episode.Exercise(problem: """
Redefine `zip` on `Parser` in terms of `flatMap` on `Parser`.
"""),
]
