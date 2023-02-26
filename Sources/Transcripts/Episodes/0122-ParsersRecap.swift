import Foundation

extension Episode {
  public static let ep122_parsersRecap = Episode(
    blurb: """
      We finish up our XCTest log parser by parsing out the data associated with a test failure. Once done we will format the results in a pretty way and package everything up in a CLI tool we can run in our own projects.
      """,
    codeSampleDirectory: "0122-parsers-recap-pt4",
    exercises: _exercises,
    id: 122,
    length: 28 * 60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_603_688_400),
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
    sequence: 122,
    subtitle: "Part 2",
    title: "Parsing Xcode Logs",
    trailerVideo: .init(
      bytesLength: 18_137_087,
      downloadUrls: .s3(
        hd1080: "0122-trailer-1080p-50d38d3a1ecb4c71a17dc7e1c3d2f96e",
        hd720: "0122-trailer-720p-2ae4987c500e449c981699b5d17c452d",
        sd540: "0122-trailer-540p-0faa6376e6d94cd8af5a2f592051ecd1"
      ),
      vimeoId: 470_758_672
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
