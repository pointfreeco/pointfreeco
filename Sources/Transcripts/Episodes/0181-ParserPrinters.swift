import Foundation

extension Episode {
  public static let ep181_parserPrinters = Episode(
    blurb: """
      Our parser-printer library is looking pretty impressive, but there are a couple problems we need to address. We have made some simplifying assumptions that have greatly reduced the generality our library aspires to have. We will address them by abstracting what it means for an input to be parseable _and_ printable.
      """,
    codeSampleDirectory: "0181-parser-printers-pt4",
    exercises: _exercises,
    id: 181,
    length: 35 * 60 + 7,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_647_234_000),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 181,
    subtitle: "Generalization",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 17_800_000,
      downloadUrls: .s3(
        hd1080: "0181-trailer-1080p-e7a15587fa854f638ff961edd7cbd56d",
        hd720: "0181-trailer-720p-b052a701b70347ce9749ab309b82cfa0",
        sd540: "0181-trailer-540p-e0e4b661c04542d188c775a6b2b4d14b"
      ),
      vimeoId: 681_614_662
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
