import Foundation

extension Episode {
  public static let ep189_tourOfParserPrinters = Episode(
    blurb: """
We conclude our tour of swift-parsing with a look at how URL routers defined as parser-printers can be automatically transformed into fully-fledged API clients, which we will drop into an iOS application and immediately use.
""",
    codeSampleDirectory: "0189-parser-printers-tour-pt5",
    exercises: _exercises,
    id: 189,
    length: 33*60 + 57,
    permission: .free,
    publishedAt:  Date(timeIntervalSince1970: 1652072400),
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
      vimeoId: 703459050
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
