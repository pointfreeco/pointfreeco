import Foundation

extension Episode {
  public static let ep178_parserPrinters = Episode(
    blurb: """
We've spent many episodes discussing parsing, which turns nebulous blobs of data into well-structured data, but sometimes we need the "inverse" process to turn well-structured data back into nebulous data. This is called "printing" and can be useful for serialization, URL routing and more. This week we begin a journey to build a unified, composable framework for parsers and printers.
""",
    codeSampleDirectory: "0178-parser-printers-pt1",
    exercises: _exercises,
    id: 178,
    length: 30*60 + 13,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1645423200),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 178,
    subtitle: "The Problem",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 58943224,
      downloadUrls: .s3(
        hd1080: "0178-trailer-1080p-724aa10874364865becf0fc1a2a3c69b",
        hd720: "0178-trailer-720p-908d57e7961d401dbe7f0c46773008d7",
        sd540: "0178-trailer-540p-d5b940e83af34d2dab7336b06a7301e8"
      ),
      vimeoId: 677916872
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
