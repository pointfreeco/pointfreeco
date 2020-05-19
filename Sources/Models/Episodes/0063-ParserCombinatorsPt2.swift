import Foundation

extension Episode {
  static let ep63_parserCombinators_pt2 = Episode(
    blurb: """
Let's solve another common parsing problem using parser combinators! It's common to want to parse multiple values off a string, and while `zip` gets us part of the way there, it doesn't let us parse _any_ number of values! Luckily there's a parser combinator that can help, and it really packs a punch.
""",
    codeSampleDirectory: "0063-parser-combinators-pt2",
    exercises: _exercises,
    id: 63,
    image: "https://i.vimeocdn.com/video/801297305.jpg",
    length: 17*60 + 59,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1561960800),
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
    sequence: 63,
    title: "Parser Combinators: Part 2",
    trailerVideo: .init(
      bytesLength: 38047077,
      downloadUrl: "https://player.vimeo.com/external/349951714.hd.mp4?s=36959b38a26352c1e8599c061b98d10d679ca044&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/349951714"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
We quickly added a `separatedBy` argument to `zeroOrMore`, but it can be very useful to parse out an array of values _without_ a separator. Give `separatedBy` a default parser for this behavior. Is this a parser we've already encountered?
"""),
  Episode.Exercise(problem: """
Add an `until` parser argument to `zeroOrMore` (and `oneOrMore`) that parses a number of values until the given parser succeeds.
"""),
  Episode.Exercise(problem: """
Make this `until` parser argument optional by providing a default parser value. Is this a parser we've already encountered?
"""),
  Episode.Exercise(problem: """
Define a parser combinator, `oneOf`, that takes an array of `Parser<A>`s as input and produces a single parser of `Parser<A>`. What can/should this parser do?
"""),
]
