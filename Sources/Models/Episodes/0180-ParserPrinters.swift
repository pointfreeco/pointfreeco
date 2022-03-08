import Foundation

extension Episode {
  public static let ep180_parserPrinters = Episode(
    blurb: """
We will chip away at more and more parser printer conformances, some of which will truly stretch our brains, but we will finally turn our complex user CSV parser into a printer!
""",
    codeSampleDirectory: "0180-parser-printers-pt3",
    exercises: _exercises,
    id: 180,
    length: 40*60 + 46,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1646632800),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 180,
    subtitle: "The Solution, Part 2",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 8457721,
      vimeoId: 680667355,
      vimeoStyle: .vimeo(
        filename: "0180-trailer.m4v",
        signature720: "aac341354a7c0da971c468da012a0bf689a712e90049ad4389ac954470f4b0ca",
        signature540: "f256e4847c10f5295d948dbd96a74d62e3f31bb10d1571321f5bbdd75bb22ec3"
      )
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
