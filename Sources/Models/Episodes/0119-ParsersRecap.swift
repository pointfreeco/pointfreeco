import Foundation

extension Episode {
  public static let ep119_parsersRecap = Episode(
    blurb: """
It's time to revisit one of our favorite topics: parsing! We want to discuss lots of new parsing topics, such as generalized parsing, performance, reversible parsing and more, but before all of that we will start with a recap of what we have covered previously, and make a few improvements along the way.
""",
    codeSampleDirectory: "0119-parsers-recap-pt1",
    exercises: _exercises,
    fullVideo: nil,
    id: 119,
    image: "https://i.vimeocdn.com/video/962585526-05aa369198e2687dad7478f26993f3cecee4d1eb7e3dfc01c6e7e520725409ff-d",
    length: 25*60 + 47,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1601874000),
    references: [
      .combinatorsDanielSteinberg,
      .parserCombinatorsInSwift,
      .regexpParser,
      .regexesVsCombinatorialParsing,
      .learningParserCombinatorsWithRust,
      .sparse,
      .parsec,
      .parseDontValidate,
      .ledgeMacAppParsingTechniques,
    ],
    sequence: 119,
    subtitle: "Part 1",
    title: "Parser Combinators Recap",
    trailerVideo: .init(
      bytesLength: 63483444,
      vimeoId: 460940404,
      vimeoSecret: "22c52944f0b5f55b5a2432f447eaf8c3733c8e08"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
