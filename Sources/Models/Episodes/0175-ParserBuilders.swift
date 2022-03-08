import Foundation

extension Episode {
  public static let ep175_parserBuilders = Episode(
    blurb: """
So what is the point of parser builders anyway? We will leverage our new builder syntax by rewriting a couple more complex parsers: a marathon parser and a URL router. This will lead us to not only clean up noise and tell a more concise parsing story, but give us a chance to create brand new parsing tools.
""",
    codeSampleDirectory: "0175-parser-builders-pt3",
    exercises: _exercises,
    id: 175,
    length: 43*60 + 43,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1643004000),
    references: [
      .init(
        author: "Brandon Williams & Stephen Celis",
        blurb: #"""
> Parsing is a surprisingly ubiquitous problem in programming. Every time we construct an integer or a URL from a string, we are technically doing parsing. After demonstrating the many types of parsing that Apple gives us access to, we will take a step back and define the essence of parsing in a single type. That type supports many wonderful types of compositions, and allows us to break large, complex parsing problems into small, understandable units.
"""#,
        link: "https://www.pointfree.co/collections/parsing",
        publishedAt: nil,
        title: "Collection: Parsing"
      ),
      .swiftParsing,
      .init(
        author: "Alex Alonso, Nate Cook, Michael Ilseman, Kyle Macomber, Becca Royal-Gordon, Tim Vermeulen, and Richard Wei",
        blurb: #"""
The Swift core team's proposal and experimental repository for declarative string processing, which includes result builder syntax for creating regular expressions, and inspired us to explore result builders for parsing.
"""#,
        link: "https://github.com/apple/swift-experimental-string-processing",
        publishedAt: referenceDateFormatter.date(from: "2021-09-29"),
        title: "Declarative String Processing"
      ),
      .manyFacesOfMap,
    ],
    sequence: 175,
    subtitle: "The Point",
    title: "Parser Builders",
    trailerVideo: .init(
      bytesLength: 46184179,
      vimeoId: 664409607,
      vimeoStyle: .vimeo(
        filename: "0175-trailer.m4v",
        signature720: "dd41216603062a89bf9e550d2f5ac1bd75c9ab219642d8761a77c95e2a01f130",
        signature540: "fe9a37aebd9a8651fdbae877d045747bed10fd7e7d2228e2de492a14cdf08780"
      )
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
