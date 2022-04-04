import Foundation

extension Episode {
  public static let ep184_parserPrinters = Episode(
    blurb: """
We conclude our series on invertible parsing by converting a more complex parser into a parser-printer, and even enhance its format. This will push us to think through a couple more fun parser-printer problems.
""",
    codeSampleDirectory: "0184-parser-printers-pt7",
    exercises: _exercises,
    id: 184,
    length: 32*60 + 45,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1649048400),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 184,
    subtitle: "The Point",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 48_000_000,
      downloadUrls: .s3(
        hd1080: "0184-trailer-540p-499b9cab4d6a470690d0982c0bfa59af",
        hd720: "0184-trailer-720p-03a3cc20db2f407db018e05ca0a84d07",
        sd540: "0184-trailer-540p-499b9cab4d6a470690d0982c0bfa59af"
      ),
      vimeoId: 686392911
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
