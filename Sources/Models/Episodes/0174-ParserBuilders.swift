import Foundation

extension Episode {
  public static let ep174_parserBuilders = Episode(
    blurb: """
Let's begin to layer result builder syntax on top of parsing. To get our feet wet, we will build a toy result builder from scratch. Then, we will dive much deeper to apply what we learn to parsers.
""",
    codeSampleDirectory: "0174-parser-builders-pt2",
    exercises: _exercises,
    id: 174,
    length: 32*60 + 8,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1642399200),
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
    ],
    sequence: 174,
    subtitle: "The Solution",
    title: "Parser Builders",
    trailerVideo: .init(
      bytesLength: 76162127,
      vimeoId: 663713620,
      vimeoSecret: "b13b0a43d23a8a73e7f34d814c51f5b10e7f4ed7"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
