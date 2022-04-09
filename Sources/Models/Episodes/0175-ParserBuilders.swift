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
      downloadUrls: .s3(
        hd1080: "0175-trailer-1080p-39962b046db34537ad19e69ea5be491c",
        hd720: "0175-trailer-720p-f18ca54674fb439497a61face7628336",
        sd540: "0175-trailer-540p-d17078648e664e898e796ea6f25e299e"
      ),
      vimeoId: 664409607
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
