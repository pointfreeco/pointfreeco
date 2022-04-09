import Foundation

extension Episode {
  public static let ep120_parsersRecap = Episode(
    blurb: """
We round out our parsing recap by reintroducing that functional trio of operators: map, zip, and flat-map. We'll use them to build up some complex parsers and make a few more ergonomic improvements to our library along the way.
""",
    codeSampleDirectory: "0120-parsers-recap-pt2",
    exercises: _exercises,
    id: 120,
    length: 38*60 + 39,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1602478800),
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
    sequence: 120,
    subtitle: "Part 2",
    title: "Parser Combinators Recap",
    trailerVideo: .init(
      bytesLength: 31096976,
      downloadUrls: .s3(
        hd1080: "0120-trailer-1080p-dd5a87fafddc4789b9693d9eea34a9f8",
        hd720: "0120-trailer-720p-6d3fa137d19e43d69f7b18e9e0983d82",
        sd540: "0120-trailer-540p-cd12657056c24567827ed5a429f864be"
      ),
      vimeoId: 460940618
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
