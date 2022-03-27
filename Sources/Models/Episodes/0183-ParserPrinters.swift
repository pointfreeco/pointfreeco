import Foundation

extension Episode {
  public static let ep183_parserPrinters = Episode(
    blurb: """
We've had to really stretch our brains to consider what it means to reverse the effects of parsing, but let's looks at some parsers that take it to the next level. They will force us to reconsider a fundamental part of printing, and will make our printers even more powerful.
""",
    codeSampleDirectory: "0183-parser-printers-pt6",
    exercises: _exercises,
    id: 183,
    length: 47*60 + 6,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1648443600),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 183,
    subtitle: "Bizarro Printing",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 145_700_000,
      downloadUrls: .s3(
        hd1080: "0183-trailer-1080p-1f55f13929314f67a5e748b122d956d3",
        hd720: "0183-trailer-720p-c0c783af06a049148bd7d8b28b06405c",
        sd540: "0183-trailer-540p-8442305bdce942ae98e9b5a4db6640e6"
      ),
      vimeoId: 686128421
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
