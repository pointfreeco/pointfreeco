import Foundation

extension Episode {
  public static let ep179_parserPrinters = Episode(
    blurb: """
      Now that we've framed the problem of printing, let's begin to tackle it. We will introduce a `Printer` protocol by "reverse-engineering" the `Parser` protocol, and we will conform more and more parsers to the printer protocol.
      """,
    codeSampleDirectory: "0179-parser-printers-pt2",
    exercises: _exercises,
    id: 179,
    length: 38 * 60 + 21,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_646_028_000),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 179,
    subtitle: "The Solution, Part 1",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 15_029_946,
      downloadUrls: .s3(
        hd1080: "0179-trailer-1080p-1d34b6eeef6b4df4a081ff30d851c7a2",
        hd720: "0179-trailer-720p-60bf8c647281492a93565ad633fd7611",
        sd540: "0179-trailer-540p-f8c5f9b4ab7b4631a988c515b8e97d04"
      ),
      vimeoId: 680_666_420
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
