import Foundation

extension Episode {
  public static let ep173_parserBuilders = Episode(
    blurb: """
Let’s revisit a favorite topic: parsing! After a short recap, we will theorize and motivate the addition of result builder syntax to our parsing library, which will help unlock a new level of ergonomics and API design.
""",
    codeSampleDirectory: "0173-parser-builders-pt1",
    exercises: _exercises,
    id: 173,
    length: 28*60 + 16,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1641794400),
    references: [
      reference(
        forCollection: .parsing,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/parsing"
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
    sequence: 173,
    subtitle: "The Problem",
    title: "Parser Builders",
    trailerVideo: .init(
      bytesLength: 46184179,
      vimeoId: 663713567,
      vimeoSecret: "1c6e3246e30699ae5241bcae875e278ea1c81a08"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
