import Foundation

extension Episode {
  public static let ep188_tourOfParserPrinters = Episode(
    blurb: """
Now that we're familiar with swift-parsing's URL router, let's take a look at Swift's most popular web framework, Vapor. We will rebuild our site router using Vapor's built-in router, and then we'll use our own companion library to power our Vapor application with a parser-printer, instead.
""",
    codeSampleDirectory: "0188-parser-printers-tour-pt4",
    exercises: _exercises,
    id: 188,
    length: 37*60 + 20,
    permission: .free,
    publishedAt:  Date(timeIntervalSince1970: 1651467600),
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
    sequence: 188,
    subtitle: "Vapor Routing",
    title: "Tour of Parser-Printers",
    trailerVideo: .init(
      bytesLength: 50_700_000,
      downloadUrls: .s3(
        hd1080: "0188-trailer-1080p-7078ef1590c243b78eb0447314ab18d3",
        hd720: "0188-trailer-720p-2278af221fdc4137b5a8c192c08fa4b0",
        sd540: "0188-trailer-540p-14ac0691d5cb447fa854f7134165656e"
      ),
      vimeoId: 703115456
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
