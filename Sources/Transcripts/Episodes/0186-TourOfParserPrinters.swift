import Foundation

extension Episode {
  public static let ep186_tourOfParserPrinters = Episode(
    blurb: """
      We continue our tour by comparing swift-parsing to Apple's forthcoming Regex DSL. After taking a look at the proposal, we'll translate an example over to be a parser-printer to compare and contrast each approach.
      """,
    codeSampleDirectory: "0186-parser-printers-tour-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 379_700_000,
      downloadUrls: .s3(
        hd1080: "0186-1080p-645b6428680743ab8de85549e443810d",
        hd720: "0186-720p-58ff1797382d4b01aa4d50fad9102a65",
        sd540: "0186-540p-7ac65266d4fd4557a2d086c60d2e1319"
      ),
      vimeoId: 697_188_902
    ),
    id: 186,
    length: 36 * 60 + 21,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_650_258_000),
    references: [
      .swiftParsing,
      .invertibleSyntaxDescriptions,
    ],
    sequence: 186,
    subtitle: "vs. Swift's Regex DSL",
    title: "Tour of Parser-Printers",
    trailerVideo: .init(
      bytesLength: 48_700_000,
      downloadUrls: .s3(
        hd1080: "0186-trailer-1080p-19163f8875a3405a9336eb0a5755bd93",
        hd720: "0186-trailer-720p-7eb415de3b5843f69356a60739ae7630",
        sd540: "0186-trailer-540p-4d2e0a43c1d042028e3a3fec5a18d9bf"
      ),
      vimeoId: 697_188_766
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 186)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
