import Foundation

extension Episode {
  public static let ep179_parserPrinters = Episode(
    blurb: """
Now that we've framed the problem of printing, let's begin to tackle it. We will introduce a `Printer` protocol by "reverse-engineering" the `Parser` protocol, and we will conform more and more parsers to the printer protocol.
""",
    codeSampleDirectory: "0179-parser-printers-pt2",
    exercises: _exercises,
    id: 179,
    length: 38*60 + 21,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1646028000),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 179,
    subtitle: "The Solution, Part 1",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 15029946,
      vimeoId: 680666420,
      vimeoStyle: .vimeo(
        filename: "0179-trailer.m4v",
        signature720: "284e47394d6484184954cee3f56b3635d3760245633d4bd28a30635d0458b5b9",
        signature540: "47c5682fa82bcbcca2b38c792632004979101b9364f188f7566db1c194d05c28"
      )
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
