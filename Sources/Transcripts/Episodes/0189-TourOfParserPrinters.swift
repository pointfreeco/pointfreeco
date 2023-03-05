import Foundation

extension Episode {
  public static let ep189_tourOfParserPrinters = Episode(
    blurb: """
      We conclude our tour of swift-parsing with a look at how URL routers defined as parser-printers can be automatically transformed into fully-fledged API clients, which we will drop into an iOS application and immediately use.
      """,
    codeSampleDirectory: "0189-parser-printers-tour-pt5",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 299_600_000,
      downloadUrls: .s3(
        hd1080: "0189-1080p-6a4477834a264a66b906e808a8e7c2d9",
        hd720: "0189-720p-4f4be45ec3bc44ec8f575064a34a7bf8",
        sd540: "0189-540p-211b577f4ddc46918b912e503a169e8f"
      ),
      vimeoId: 703_459_287
    ),
    id: 189,
    length: 33 * 60 + 57,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_652_072_400),
    references: [
      .vaporRouting,
      .swiftParsing,
      .invertibleSyntaxDescriptions,
      .init(
        blurb: #"""
          A popular Swift web framework. It comes with a router that is clearly inspired by frameworks like Express, but as a result is less type safe than it could be.
          """#,
        link: "https://vapor.codes",
        title: "Vapor"
      ),
    ],
    sequence: 189,
    subtitle: "API Clients for Free",
    title: "Tour of Parser-Printers",
    trailerVideo: .init(
      bytesLength: 42_200_000,
      downloadUrls: .s3(
        hd1080: "0189-trailer-1080p-728a412e2e1044c8918d8322e0534db9",
        hd720: "0189-trailer-720p-44b216ce66754f459dd8892ebd04cc96",
        sd540: "0189-trailer-540p-ec9cc99f9e2f4c1a9564687441f2fd5c"
      ),
      vimeoId: 703_459_050
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 189)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
