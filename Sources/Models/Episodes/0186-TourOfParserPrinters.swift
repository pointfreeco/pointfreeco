import Foundation

extension Episode {
  public static let ep186_tourOfParserPrinters = Episode(
    blurb: """
TODO
""",
    codeSampleDirectory: "0186-parser-printers-tour-pt2",
    exercises: _exercises,
    id: 186,
    length: 36*60 + 21,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1650258000),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 186,
    subtitle: "vs. Regex",
    title: "Tour of Parser-Printers",
    trailerVideo: .init(
      bytesLength: 48_700_000,
      downloadUrls: .s3(
        hd1080: "0186-trailer-1080p-19163f8875a3405a9336eb0a5755bd93",
        hd720: "0186-trailer-720p-7eb415de3b5843f69356a60739ae7630",
        sd540: "0186-trailer-540p-4d2e0a43c1d042028e3a3fec5a18d9bf"
      ),
      vimeoId: 697188766
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
