import Foundation

extension Episode {
  public static let ep121_parsersRecap = Episode(
    blurb: """
      Now that we've refamiliarized ourselves with parsing, let's parse something even more complex: XCTest logs. We will parse and pretty-print the output from `xcodebuild` and discover more reusable combinators along the way.
      """,
    codeSampleDirectory: "0121-parsers-recap-pt3",
    exercises: _exercises,
    id: 121,
    length: 31 * 60 + 3,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_603_083_600),
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
    sequence: 121,
    subtitle: "Part 1",
    title: "Parsing Xcode Logs",
    trailerVideo: .init(
      bytesLength: 45_637_085,
      downloadUrls: .s3(
        hd1080: "0121-trailer-1080p-c5d4c8aea261405dae3109cfc0bd0b80",
        hd720: "0121-trailer-720p-3245fc303c4346f4b505e133f1caf303",
        sd540: "0121-trailer-540p-2001ca2054d64f8da4d6d559c072146d"
      ),
      vimeoId: 469_007_590
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
