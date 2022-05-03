import Foundation

extension Episode {
  public static let ep119_parsersRecap = Episode(
    blurb: """
      It's time to revisit one of our favorite topics: parsing! We want to discuss lots of new parsing topics, such as generalized parsing, performance, reversible parsing and more, but before all of that we will start with a recap of what we have covered previously, and make a few improvements along the way.
      """,
    codeSampleDirectory: "0119-parsers-recap-pt1",
    exercises: _exercises,
    fullVideo: nil,
    id: 119,
    length: 25 * 60 + 47,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_601_874_000),
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
    sequence: 119,
    subtitle: "Part 1",
    title: "Parser Combinators Recap",
    trailerVideo: .init(
      bytesLength: 63_483_444,
      downloadUrls: .s3(
        hd1080: "0119-trailer-1080p-2d56b11f471f4e14aa50b9be645764cd",
        hd720: "0119-trailer-720p-f30672b2a5794cbcb4df78019673451a",
        sd540: "0119-trailer-540p-e8e547821932495d8893df7a2e9d19b3"
      ),
      vimeoId: 460_940_404
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
