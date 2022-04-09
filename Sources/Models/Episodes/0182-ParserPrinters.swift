import Foundation

extension Episode {
  public static let ep182_parserPrinters = Episode(
    blurb: """
Our parser-printer library is looking incredible, but there's a glaring problem that we have no yet addressed. We haven't been able to make one of our favorite operations, `map`, printer-friendly. The types simply do not line up. This week we will finally address this shortcoming.
""",
    codeSampleDirectory: "0182-parser-printers-pt5",
    exercises: _exercises,
    id: 182,
    length: 56*60 + 46,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1647838800),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 182,
    subtitle: "Map",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 17_800_000,
      downloadUrls: .s3(
        hd1080: "0182-trailer-1080p-e7a15587fa854f638ff961edd7cbd56d",
        hd720: "0182-trailer-720p-b052a701b70347ce9749ab309b82cfa0",
        sd540: "0182-trailer-540p-e0e4b661c04542d188c775a6b2b4d14b"
      ),
      vimeoId: 681614662
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
